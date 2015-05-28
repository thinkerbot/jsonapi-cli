Print requests in order

  # N METHOD url
  # headers (optional -H)
  payload (no ids, or ids depending on method)
  # response (optional -P)

After printing resource creation, print relationship creation.
* order resource creation parent-child
* toposort relationship creation
* warn/error if relationships are circular
* use {{id}} in relationships to reference requests if no ids specified

If ids are specified, alternatively print final cache.
