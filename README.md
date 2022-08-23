# Gitops Apps

Gitops driven apps deployment with ArgoCD to k8s using Helm charts.

## Environments

Environments are managed in separate branches of this repository, one branch per environment.
All environments must be kept in parity in terms of applications, common configuration and versions.

| Name          | Codename      | Audience              | Availability  | Data Persistence | Data Backups     |
| ------------- | ------------- | -------------         | ------------- | ---------------- | ---------------- |
| Development   | `dev`         | devops, developers    | n/a           | ephemeral        | no               |
| Staging       | `stg`         | developers as users   | 90%           | ephemeral        | no               |
| Production    | `prd`         | general public users  | 99.5%         | ephemeral        | yes (TBD policy) |

### Development

Development environment should be used only for testing purposes of deployment and integration, for example during chart creation or configuration changes. There is no availability guaranteed - the environment can get down at anytime for any period of time.

### Staging

Staging environment can be used to showcase development changes and progress to other developers/internals, for example PR review deployments. However, deployments in this environment should not be shared to users/externals. The availability of the environment is low and it can get down anytime, no planned downtime windows.


### Production

As the name implies this is user facing environment with strong availability and planned downtime windows announced in advance.
The availability of the environment shall be kept as high as possible.

## Persistence

This k9s cluster setup provides only ephemeral data persistence, that is [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) can be used but only for the lifespan of the given cluster. If for some reason an environment cluster needs to be re-created for whatever reason all data would be lost.

Thus, it is mandatory to use external storage services like: S3, RDS, OpenSearch, ElastiCache, etc.

## Promotion

It is mandatory to keep the promotion path as `dev` -> `stg` -> `prd`.
This essentially means that each change start in the `dev` branch and gets promoted forward to `prd`.
During promotion all changes are overwritten except environment specific configuration in the corresponding value files.
This of course exclude environment specific configuration (values files) and it can be changed directly into the corresponding branch.
