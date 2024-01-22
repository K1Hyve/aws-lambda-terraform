# Migration Plan

0. Making sure all relavant parties in the company are aware of planned changes and have a rough timeline for planned changes.
1. Having proper automated end to end tests, ideally unit tests and integration tests are also present. This is will faciliate finding errors and misconfigurations faster. 
2. Making sure the automated infrastructure code is present and up to date.
3. Creating a seperate environment for development and deploying the stack there.
4. Running test suite on the new environment to make sure the stack is working.
5. Helping development teams with migration to the new environment and finding final quirks and misconfigurations and updaing IaC.
6. If possible, monitor API error rates and failed calls to ensure the environment is stable and wait until pace of the development process is back to normal.
7. Migrate the next environment to a new VPC and repeat steps 3 until 6 but with more focus on the monitoring and making sure CI/CD pipelines remain functional.
8. For migrating the production environment, an additional step would be transferring the traffic with canary method, in order to reduce risk of downtimes and failures.

This plan can be changed with more steps or less steps depending on requirements of the company and the applications.

