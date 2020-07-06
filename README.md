# Douban Charts Repo

[![](https://github.com/douban/charts/workflows/Release%20Charts/badge.svg?branch=master)](https://github.com/douban/charts/actions)

Douban charts

## How to use
1. Install helm
2. Add douban repo `helm repo add douban https://douban.github.io/charts/`
3. List charts using `helm search repo douban`
4. Install chart using `helm install my-app douban/<chart-name>`, eg. `helm install my-helpdesk douban/helpdesk`

Read more on the charts readme pages.


## Chart List

* [nginx](https://github.com/douban/charts/charts/nginx) for general web service
* [helpdesk](https://github.com/douban/charts/charts/helpdesk), [@douban/helpdesk](https://github.com/douban/helpdesk) Yet another helpdesk based on multiple providers
* [overlord](https://github.com/douban/charts/charts/overlord), [@bilibili/overlord](https://github.com/bilibili/overlord)


## Thanks to 

* [@helm/charts-repo-actions-demo](https://github.com/helm/charts-repo-actions-demo)
* [@helm/kind-action](https://github.com/helm/kind-action)
* [@helm/chart-testing-action](https://github.com/helm/chart-testing-action)
* [@helm/chart-releaser-action](https://github.com/helm/chart-releaser-action)
