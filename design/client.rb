# Cache-based JSONAPI mock

def list(type)
  resources = list_from_server(type, id)
  resources.each do |resource|
    set_to_cache(resource)
  end
  resources
end

def get(type, id)
  resource = get_from_cache(type,id)
  if resource.nil?
    resource = get_from_server(type, id)
    set_to_cache(resource)
  end
  resource
end

def put(resource)
  resource = put_to_server(resource)
  set_to_cache(resource)
end

def post(resource)
  resource = post_to_server(resource)
  set_to_cache(resource)
end

def patch(resource)
  curr_resource = get_from_cache(resoure.type, resource.id)
  resource = patch_to_server(resource, curr_resource) # curr resource is optional, sets diff
  set_to_cache(resource)
end

def delete(resource)
  delete_to_server(resource)
  delete_from_cache(resource)
  resoure
end

# Hmmm... don't force this on the client side because the client may want no cache.

# optional...
resources = service.list(type)
cache.add(resources)

cache.list(type)
cache.get(type, id)

# On the server side you can set up the list/get mock based off of a single state.
# You need state transistions from then on.
# generate could put out the state by default "here is the storage of the server where you have x of this and y of that"
# then output the transitions from state x to state y

# the thing is that there may be no good on-disk intermediate.  states -- ok, individual request-reply -- ok.
# maybe map out all the states then pick out the meaningful examples


