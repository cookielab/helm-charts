# Helm Charts

Open source Helm charts and libraries for Kubernetes deployments.

## Repository URL
https://helm.cookielab.dev

## GitHub Repository
https://github.com/cookielab/helm-charts

## Artifact Hub publishing

The release workflow publishes packaged charts, `index.yaml` and
`artifacthub-repo.yml` to https://helm.cookielab.dev using S3 and CloudFront.
Artifact Hub indexes this existing repository. No separate chart upload is needed.

To set up the listing:

1. Sign in to https://artifacthub.io and create or select the Cookielab organization.
2. In the control panel, add a Helm charts repository named `cookielab` with URL
   `https://helm.cookielab.dev`. If the URL is already registered, follow Artifact
   Hub's [ownership claim instructions](https://artifacthub.io/docs/topics/repositories/#ownership-claim).
3. Copy the repository ID from the control panel into `artifacthub-repo.yml`,
   replacing `{}` with `repositoryID: <the assigned ID>`.
4. Commit the metadata alongside a new chart version and merge to `main`. The
   release workflow publishes both. Artifact Hub checks publisher verification
   when it next processes the changed repository index. Changing only the index's
   `generated` timestamp does not trigger processing.

Registration indexes all charts in this repository. Subsequent chart releases
are indexed automatically. Keep release notes for each `complex` version in its
`artifacthub.io/changes` annotation, and regenerate its README after metadata or
documentation changes with `./scripts/update-docs.sh complex`.

The `complex` chart deploys user-supplied container images and requires image
values. Its default values do not render a workload, so Artifact Hub cannot
automatically discover application images for security reports. The
[installation example](complex/README.md#installation) supplies an image and a
component. Reports for a listing cannot cover the images chosen by each user.

See the [Helm repository documentation](https://artifacthub.io/docs/topics/repositories/helm-charts/)
and [publisher verification requirements](https://artifacthub.io/docs/topics/repositories/#verified-publisher).

## Charts

### Application Charts
- **complex** - Main application chart with comprehensive deployment options
- **prometheus-rules** - Prometheus alerting and recording rules

### Library Charts
- **lib-datadog** - Datadog monitoring library
- **lib-gitlab** - GitLab integration library  
- **lib-kubernetes** - Kubernetes utilities library
- **lib-prometheus** - Prometheus monitoring library
