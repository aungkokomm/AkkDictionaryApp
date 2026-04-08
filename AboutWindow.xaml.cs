using System.Diagnostics;
using System.Windows;

namespace AkkDictionaryApp
{
    public partial class AboutWindow : Window
    {
        public AboutWindow()
        {
            InitializeComponent();
        }

        private void Hyperlink_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                Process.Start(new ProcessStartInfo
                {
                    FileName = "https://github.com/aungkokomm/English-Myanmar-Dictionary-",
                    UseShellExecute = true
                });
            }
            catch { }
        }

        private void Close_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }
    }
}
