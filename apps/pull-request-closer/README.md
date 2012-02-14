# Pull request closer

This app waits for Github to post JSON to it when a pull request is opened and
then closes the pull request with a configurable comment.

# How does it work?

We query the Github API for a list of open pull requests and close them with
a message.

## In more detail

First we get the public events for the cloudfoundry Github organization

    curl -i https://api.github.com/orgs/cloudfoundry/events

We then find all events of type "PullRequestEvent" with a status of 'open'.

All these open pull requests are closed with a configurable comment.

# Author

Jonathan "Duke" Leto

# Copyright

Copyright (C) 2012 VMware, Inc. All rights reserved.

# License

Apache 2.0
