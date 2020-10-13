# BazaarRealmMod

Contains all of the Papyus script sources, the ESP plugin, and all other mod resources for the Bazaar Realm Skyrim mod.

Related projects:

* [`BazaarRealmPlugin`](https://github.com/thallada/BazaarRealmPlugin):
  [SKSE](https://skse.silverlock.org/) plugin for the mod that modifies data
  within the Skyrim game engine
* [`BazaarRealmAPI`](https://github.com/thallada/BazaarRealmAPI): API server
  for the mod that stores all shop data
* [`BazaarRealmClient`](https://github.com/thallada/BazaarRealmClient): DLL that
  handles requests and responses to the API from the SKSE plugin

## Compiling Scripts

Change the Skyrim path in `tasks.json`, then with the workspace loaded in
Visual Studio Code, `control + shift + B` will compile the scripts into the
`Scripts` folder. Copy and paste these into the Skyrim Data folder.