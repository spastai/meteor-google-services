Package.describe({
  summary: "Google services client",
  version: "0.0.3",
  git: " \* Fill me in! *\ "
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@0.9.0');
  api.use("spastai:flow-controll", ["client", "server"]);
  api.use(["coffeescript", "underscore" ], ["client", "server"]);
  api.add_files('SlowQueue.js', 'client');
  api.add_files('ParallelQueue.js', 'client');
  api.add_files('Geocoder.js', 'client');
  api.add_files('Directions.js', 'client');
  api.add_files('GoogleServicesClient.coffee', 'client');
  if (api.export) api.export(['Geocoder'], 'client');
  if (api.export) api.export(['ParallelQueue'], 'client');
  if (api.export) api.export(['Directions'], 'client');
  if (api.export) api.export(['googleServices'], 'client');
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('spastai:google-client');
  api.addFiles('spastai:google-client-tests.js');
});
