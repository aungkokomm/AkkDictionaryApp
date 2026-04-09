using Android.App;
using Android.OS;
using Android.Widget;

namespace AkkDictionary.Android;

[Activity(Label = "@string/app_name", MainLauncher = true)]
public class MainActivity : Activity
{
    protected override void OnCreate(Bundle? savedInstanceState)
    {
        base.OnCreate(savedInstanceState);
        SetContentView(Resource.Layout.activity_main);

        // Find UI elements
        var searchInput = FindViewById<EditText>(Resource.Id.searchInput);
        var searchButton = FindViewById<Button>(Resource.Id.searchButton);
        var resultsView = FindViewById<ListView>(Resource.Id.resultsView);

        if (searchButton != null)
        {
            // Wire up search button click
            searchButton.Click += (s, e) =>
            {
                string query = searchInput?.Text ?? "";
                Toast.MakeText(this, "Search for: " + query, ToastLength.Short)?.Show();
            };
        }
    }
}