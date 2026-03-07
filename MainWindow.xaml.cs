using Microsoft.Data.Sqlite;
using System.Collections.ObjectModel;
using System.Data;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using Microsoft.Win32;
using System.Text.Json;
using System.Windows.Input;
using System.Windows.Media;

namespace AkkDictionaryApp
{
    public partial class MainWindow : Window
    {
        private readonly string _dbPath;
        private readonly ObservableCollection<EntryRow> _results = new();
        private bool _reverseSearch = false;
        private AppSettings _settings = AppSettings.Load(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "settings.json"));

        public MainWindow()
        {
            InitializeComponent();
            ResultsList.ItemsSource = _results;
            _dbPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "dictionary.db");
            ApplySettings();
        }

        private void OpenSettings_Click(object sender, RoutedEventArgs e)
        {
            var settingsWin = new SettingsWindow { Owner = this };
            if (settingsWin.ShowDialog() == true)
            {
                _settings = AppSettings.Load(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "settings.json"));
                ApplySettings();
            }
        }

        private void ApplySettings()
        {
            try
            {
                this.FontFamily = new FontFamily(string.IsNullOrWhiteSpace(_settings.UiFontFamily) ? "Myanmar Text" : _settings.UiFontFamily);
                this.FontSize = 14 * _settings.FontScale;
                ReverseSearchToggle.IsChecked = _settings.DefaultReverseSearch;
                ReverseSearchMenu.IsChecked = _settings.DefaultReverseSearch;
            }
            catch {}
        }

        private async void SearchBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            var q = SearchBox.Text?.Trim() ?? string.Empty;
            await LoadResultsAsync(q);
            await LoadSuggestionsAsync(q);
        }

        private async Task LoadSuggestionsAsync(string query)
        {
            if (_reverseSearch || !_settings.EnableSuggestions || string.IsNullOrWhiteSpace(query))
            { SuggestList.Visibility = Visibility.Collapsed; return; }
            if (!File.Exists(_dbPath)) { SuggestList.Visibility = Visibility.Collapsed; return; }

            using var conn = new SqliteConnection(new SqliteConnectionStringBuilder { DataSource = _dbPath }.ToString());
            await conn.OpenAsync();
            var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT DISTINCT display_headword FROM entries WHERE search_key LIKE @starts ORDER BY display_headword LIMIT 10";
            cmd.Parameters.AddWithValue("@starts", (query.ToLower() + "%"));
            using var rdr = await cmd.ExecuteReaderAsync();
            var list = new ObservableCollection<string>();
            while (await rdr.ReadAsync()) list.Add(rdr.GetString(0));
            SuggestList.ItemsSource = list;
            SuggestList.Visibility = list.Count > 0 ? Visibility.Visible : Visibility.Collapsed;
        }

        private async Task LoadResultsAsync(string query)
        {
            _results.Clear();
            SensesPanel.ItemsSource = null;
            if (!File.Exists(_dbPath)) return;

            using var conn = new SqliteConnection(new SqliteConnectionStringBuilder{ DataSource = _dbPath }.ToString());
            await conn.OpenAsync();

            var cmd = conn.CreateCommand();
            if (!_reverseSearch)
            {
                cmd.CommandText = @"
WITH q AS (SELECT @q AS q)
SELECT display_headword, pos, COUNT(*) AS senses, 1 AS rank
  FROM entries, q WHERE search_key = q.q
  GROUP BY display_headword, pos
UNION ALL
SELECT display_headword, pos, COUNT(*) AS senses, 2 AS rank
  FROM entries, q WHERE search_key LIKE (q.q || '%') AND search_key <> q.q
  GROUP BY display_headword, pos
UNION ALL
SELECT display_headword, pos, COUNT(*) AS senses, 3 AS rank
  FROM entries, q WHERE search_key LIKE ('%' || q.q || '%') AND search_key NOT LIKE (q.q || '%')
  GROUP BY display_headword, pos
ORDER BY rank, display_headword
LIMIT 400;";
                cmd.Parameters.AddWithValue("@q", (query ?? string.Empty).ToLower());
            }
            else
            {
                cmd.CommandText = @"SELECT display_headword, pos, COUNT(*) AS senses FROM entries WHERE definition LIKE @mm GROUP BY display_headword, pos ORDER BY display_headword LIMIT 400";
                cmd.Parameters.AddWithValue("@mm", "%" + (query ?? string.Empty) + "%");
            }

            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                _results.Add(new EntryRow
                {
                    DisplayHeadword = reader.GetString(0),
                    Pos = reader.IsDBNull(1) ? string.Empty : reader.GetString(1),
                    Senses = reader.GetInt32(2)
                });
            }
        }

        private async void ResultsList_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (ResultsList.SelectedItem is not EntryRow row) { SensesPanel.ItemsSource = null; return; }
            if (!File.Exists(_dbPath)) return;

            using var conn = new SqliteConnection(new SqliteConnectionStringBuilder{ DataSource = _dbPath }.ToString());
            await conn.OpenAsync();
            var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT definition FROM entries WHERE display_headword = @hw AND (pos = @pos OR (@pos = '' AND (pos IS NULL OR pos = ''))) ORDER BY definition LIMIT 500";
            cmd.Parameters.AddWithValue("@hw", row.DisplayHeadword);
            cmd.Parameters.AddWithValue("@pos", row.Pos ?? string.Empty);

            var items = new ObservableCollection<StackPanel>(); int i=0;
            using var rdr = await cmd.ExecuteReaderAsync();
            while (await rdr.ReadAsync())
            {
                i++;
                var def = rdr.GetString(0);
                var tb = new TextBlock { TextWrapping = TextWrapping.Wrap };
                BuildDefinitionInlines(tb, def);
                var sp = new StackPanel { Orientation = Orientation.Horizontal };
                sp.Children.Add(new TextBlock { Text = i.ToString() + ". ", Width = 28 });
                sp.Children.Add(tb);
                items.Add(sp);
            }
            SensesPanel.ItemsSource = items;
        }

        private void BuildDefinitionInlines(TextBlock tb, string definition)
        {
            tb.Inlines.Clear();
            int idx = 0; var matches = Utils.FindSeeAlso(definition).ToList();
            if (matches.Count == 0) { tb.Inlines.Add(new Run(definition)); return; }
            foreach (var m in matches)
            {
                if (m.start > idx) tb.Inlines.Add(new Run(definition.Substring(idx, m.start - idx)));
                var term = definition.Substring(m.start, m.length);
                var link = new Hyperlink(new Run(term));
                link.Click += (_, __) => { SearchBox.Text = term; };
                tb.Inlines.Add(link);
                idx = m.start + m.length;
            }
            if (idx < definition.Length) tb.Inlines.Add(new Run(definition.Substring(idx)));
        }

        private async void Clear_Click(object sender, RoutedEventArgs e)
        { SearchBox.Text = string.Empty; await LoadResultsAsync(string.Empty); SuggestList.Visibility = Visibility.Collapsed; }

        private async void ReverseSearchToggle_CheckedChanged(object sender, RoutedEventArgs e)
        {
            _reverseSearch = ReverseSearchToggle.IsChecked == true;
            ReverseSearchMenu.IsChecked = _reverseSearch;
            await LoadResultsAsync(SearchBox.Text?.Trim() ?? string.Empty);
        }

        private async void ReverseSearchMenu_Checked(object sender, RoutedEventArgs e)
        {
            _reverseSearch = ReverseSearchMenu.IsChecked == true;
            ReverseSearchToggle.IsChecked = _reverseSearch;
            await LoadResultsAsync(SearchBox.Text?.Trim() ?? string.Empty);
        }

        private async void ReverseSearchMenu_Unchecked(object sender, RoutedEventArgs e)
        {
            _reverseSearch = false;
            ReverseSearchToggle.IsChecked = false;
            await LoadResultsAsync(SearchBox.Text?.Trim() ?? string.Empty);
        }

        private void About_Click(object sender, RoutedEventArgs e)
        { MessageBox.Show(@"AKK En-to-MM Dictionary

Built with .NET 8 + WPF + SQLite.", "About"); }

        private void Exit_Click(object sender, RoutedEventArgs e) => Close();

        private async void RebuildFromExcel_Click(object sender, RoutedEventArgs e)
        {
            var dlg = new OpenFileDialog { Filter = "Excel (*.xlsx)|*.xlsx|All files (*.*)|*.*" };
            if (dlg.ShowDialog() == true)
            {
                try
                {
                    Mouse.OverrideCursor = System.Windows.Input.Cursors.Wait;
                    Utils.RebuildDatabaseFromExcel(dlg.FileName, _dbPath);
                    await LoadResultsAsync(SearchBox.Text?.Trim() ?? string.Empty);
                    MessageBox.Show("Database rebuilt successfully.", "Success");
                }
                catch (System.Exception ex)
                { MessageBox.Show(ex.Message, "Rebuild failed", MessageBoxButton.OK, MessageBoxImage.Error); }
                finally { Mouse.OverrideCursor = null; }
            }
        }

        private async void SuggestList_MouseDoubleClick(object sender, System.Windows.Input.MouseButtonEventArgs e)
        { if (SuggestList.SelectedItem is string s){ SearchBox.Text = s; await LoadResultsAsync(s); SuggestList.Visibility = Visibility.Collapsed; } }

        private async void SearchBox_KeyDown(object sender, System.Windows.Input.KeyEventArgs e)
        { if (e.Key == System.Windows.Input.Key.Enter){ await LoadResultsAsync(SearchBox.Text?.Trim() ?? string.Empty); SuggestList.Visibility = Visibility.Collapsed; } }

        private async void ImportFromSqlite_Click(object sender, RoutedEventArgs e)
        {
            var win = new SqliteImportWindow { Owner = this };
            if (win.ShowDialog() == true && !string.IsNullOrWhiteSpace(win.SourcePath))
            {
                try
                {
                    Mouse.OverrideCursor = System.Windows.Input.Cursors.Wait;
                    Utils.RebuildDatabaseFromSqlite(win.SourcePath!, win.TableName!, win.HeadCol!, win.DefCol!, win.PosCol, _dbPath);
                    await LoadResultsAsync(SearchBox.Text?.Trim() ?? string.Empty);
                    MessageBox.Show("Imported successfully from SQLite.", "Success");
                }
                catch (System.Exception ex)
                { MessageBox.Show(ex.Message, "Import failed", MessageBoxButton.OK, MessageBoxImage.Error); }
                finally { Mouse.OverrideCursor = null; }
            }
        }
    }

    public sealed class EntryRow
    {
        public string DisplayHeadword { get; set; } = string.Empty;
        public string Pos { get; set; } = string.Empty;
        public int Senses { get; set; }
    }
}
