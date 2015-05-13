# JSONAPI CDC

## Client side

The project can run a server that sends predefined responses for a set of known requests.  These requests outline the contract between the server and client.  As a first run assume that it will be sufficient to provide static responses such that no request can modify any response, and the same response will be given for any request.  The requests might be modeled as a graph of state transitions to the resource cache.

Example limitiations:

* Only the predefined transitions in a set of requests will be allowed.  Other requests have undefined behavior and so will error.
* Dates will be fixed so time calculations on the client will skew as time progresses.

Justification:

JSONAPI builds in the idea of a cache keyed by "type,id".  If the server is considered to be the canonical version of that cache then it makes sense to describe requests as fixed reads of the cache, or state transitions in the cache.  Most CRUD should be able to be modeled along these lines.

## Server side

The project can run a client that sends a predefined set of requests against the server, and then validate the responses.  Because the server will exist, the responses can have dynamic parts that could require dynamic validation.  The client can be modeled as the server in reverse.  Requests contact the server then modify the client's cache, which then gets validated using whatever rules are desired.

## Caches

The caches can be viewed as the nodes in a state graph and the request/respones as the edges.  For the client that means it will have to track edge transitions within an actual response cache as well as the expected responses in a validation cache.

  actual   = {type,id => json}
  expected = {type,id => json}

Not all fields can be pre-defined in the expected cache. Specifically server-generated values like ids cannot be known beforehand... other exampes include dates, sanitized values, and server auditing information.  That means the expected cache must allow for that.  One way to do this is by composing the expected cache from objects that can reference one another, and then produce the fixed content in the actual cache.  

  expected = {type,resource_id => resource}
  resource.to_json(:cache => expected) # => actual_json

Or use the expected cache to validate the actual cache, where internally it will check the presence of resources and validate fields.

  expected.validate(actual)

Both caches are needed on the cdc-client to validate the server.  The actual client is assumed to know what requests (edges) are possible and to track the cache, or not, as it prefers.  The cdc-server can generate responses based off of the expected cache.  In that way the edges indicate:

  { parent-cache, child-cache, request, response }

Where the request might be some matcher value if there is some data the server cannot know beforehand (like client audit information) and the response is an identifer for which resource to render.

