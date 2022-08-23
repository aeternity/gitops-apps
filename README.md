# Gitops Apps

Gitops driven apps deployment with ArgoCD to k8s using Helm charts.

## Environments

Environments are managed in separate branches of this repository, one branch per environment.
All environments must be kept in parity in terms of applications, common configuration and versions.

| Name          | Codename  | EKS name    | Audience              | Availability  | Data Persistence | Data Backups     |
| ------------- | --------- | ----------- | -------------         | ------------- | ---------------- | ---------------- |
| Development   | `dev`     | dev-wgt7    | devops, developers    | n/a           | ephemeral        | no               |
| Staging       | `stg`     | stg-m4n4    | developers as users   | 90%           | ephemeral        | no               |
| Production    | `prd`     | prd-0e9c    | general public users  | 99.5%         | ephemeral        | yes (TBD policy) |

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

## Chart Scaffold

To deploy a new application to the cluster one needs to create a [Helm Chart](https://helm.sh/docs/topics/charts/) that extends the base chart.

There is a little script that can do the scaffolding ($APP replacement) explained below for you given an application name:
```bash
./scripts/scaffold.sh myapp
```

1. Start by copying the scaffold chart assuming application name being `myapp`. Skip this step if you run the scaffold script:
    ```bash
    export APP=myapp
    cp -r scaffold $APP
    ```
1. Open `myapp/values.yaml` and adjust the configuration:
    1. Replace occurrence of `$APP` with your application name, i.e. `myapp`.
    1. Adjust the repository name. If the image name is the same as the chart name (myapp) it can be omitted.
    1. Adjust the secrets. Ask a devops team member to create a secret for you. If your app does not need any secrets: the section can be omitted.
    1. Adjust the service port. If it's 80 (the default), it can be omitted.
    1. Adjust the versions. If the application requires multiple version to be deployed simultaneously list all of them. If only a single version is needed omit the section and adjust the `image.tag`
    1. Adjust the Ingress. If your app does not need incoming external traffic, omit the section (it's disabled by default)
1. Open `myapp/values-dev.yaml` and adjust the configuration:
    1. Replace occurrence of `$APP` with your application name, i.e. `myapp`.
    1. Adjust the secrets. Set the correct EKS name as remove prefix. If the application does not need secrets omit the section.
    1. Adjust the ingress. If the application does not need incoming external traffic, omit the section.
        1. Adjust the `stripPrefix`. If the application have multiple version deployed behind multiple paths, adjust the `stripPrefix` to drop the prefix when the requests are routed.
        1. Adjust the hosts. If the application is deployed on multiple domains list them and adjust the corresponding paths.
        1. Adjust the `paths`. Each path can be routed to different application version. If the application deploys a single version, the `version` key for `paths` can be omitted.
        1. Adjust TLS. List all hosts used in the `hosts` configuration above and set a unique `secretName`
1. Open `myapp/values-stg.yaml` and adjust the configuration using the same steps as above.
1. Open `myapp/values-prd.yaml` and adjust the configuration using the same steps as above.
