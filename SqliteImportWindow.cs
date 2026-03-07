using System.Windows;
using Microsoft.Win32;

namespace AkkDictionaryApp
{
    public partial class SqliteImportWindow : Window
    {
        public string? SourcePath { get; set; }
        public string? TableName { get; set; }
        public string? HeadCol { get; set; }
        public string? DefCol { get; set; }
        public string? PosCol { get; set; }

        public SqliteImportWindow()
        {
            InitializeComponent();
        }

        private void BrowseButton_Click(object sender, RoutedEventArgs e)
        {
            var dlg = new OpenFileDialog { Filter = "SQLite (*.db)|*.db|All files (*.*)|*.*" };
            if (dlg.ShowDialog() == true)
            {
                SourcePathTextBox.Text = dlg.FileName;
            }
        }

        private void OKButton_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(SourcePathTextBox.Text) ||
                string.IsNullOrWhiteSpace(TableNameTextBox.Text) ||
                string.IsNullOrWhiteSpace(HeadColTextBox.Text) ||
                string.IsNullOrWhiteSpace(DefColTextBox.Text))
            {
                MessageBox.Show("Please fill in all required fields.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            SourcePath = SourcePathTextBox.Text;
            TableName = TableNameTextBox.Text;
            HeadCol = HeadColTextBox.Text;
            DefCol = DefColTextBox.Text;
            PosCol = string.IsNullOrWhiteSpace(PosColTextBox.Text) ? null : PosColTextBox.Text;

            this.DialogResult = true;
            this.Close();
        }

        private void CancelButton_Click(object sender, RoutedEventArgs e)
        {
            this.DialogResult = false;
            this.Close();
        }
    }
}
