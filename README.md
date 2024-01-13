# Minimalistic project management library

Projects as could be defined a DevOps.

## What is a project?

A directory with associated configuration

* Welcome message
* Custom Variables
* Python Virtual env

## What does this tool do?

Load configuration into session, like:

* Set Python Virtualenv
* Update PATH variable
* Segregate different projects into different paths
* Helps you track when you are working on a specific project
* Much more: anything you want defined in the configuration of the project
## Next steps

* Currently a series of bash shell functions
* Almost completed migration to python
* I am already thinking to migrate to go instead: Spead, single binary

## Function documentation

"projects" is a collection of function that are loaded to be loaded the user (bash) environment

| Name       | Description                              |
| ---------- | ---------------------------------------- |
| psave      | Add project to database                  |
| pclass     | Unimplemented                            |
| pload      | Load project configuration into session  |
| preload    |                           |
| pdel       | Delete project from database             |
| plist      | List all defined projects                |
| phelp      |                           |
| pattr      | Unimplemented                         |
| pinfo      | Retrieve directory                    |
| pdir       | Get project directory                 |
| pedit      | Edit project definition file          |
| penv       |                           |
| penvlist   |                           |
| pvenv      | Unimplemented                          |
