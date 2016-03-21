# Environment Configuration Folder

This folder hosts the configuration for each environment which can be deployed by this jenkins docker slave.

## Configuration folder
 
- Each subdirectory represents a environment.
- The directories must not be committed to vcs.

### Minimum Configuration Set

- `env.properties` with following entries
  - `datadir` - the absolute path to our nfs entry point 
     - (after this entry the next sub-level should contain folders like `1`, `2`…)
  - `webport` - the port mapping for this container (like 0.0.0.0:8088)
- `config.properties` with combined configuration set from `amak-frontend`, `amak-cms` and `amak-portal`.


### Other Configuration Files

- `env.properties` with following entries
  - `environment` - the environment to run the application (development, testing, production)