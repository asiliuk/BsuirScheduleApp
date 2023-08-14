devices([
    "iPhone 8 Plus", # 5.5" Display
    "iPhone 11 Pro Max", # 6.5" Display
    "iPhone 14 Pro Max", # 6.7" Display
    "iPad Pro (12.9-inch) (6th generation)",
])

languages([
  "en-US",
  "ru-RU",
  "be-BY",
  "uk-UA",
])

# Speedup things by skipping packages version resolution
skip_package_dependencies_resolution(true)

# The name of the scheme which contains the UI Tests
scheme("AppStoreSnapshotsUITests")

# Where should the resulting screenshots be stored?
output_directory("./img/snapshots")

# clear all previously generated screenshots before creating new ones
clear_previous_screenshots(true)

# set the status bar to 9:41 AM, and show full battery and reception. See also override_status_bar_arguments for custom options.
override_status_bar(true)
