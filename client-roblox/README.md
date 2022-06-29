## Methods

### nodeDatastore

#### object nodeDatastore:GetDataStore(string *name*)
Returns a **datastore** object with the given name.

---

### datastore

#### table datastore:GetAsync(string *key*, bool *ignoreCache*)
Gets data in table format, using the given key. Ignores cache when *ignoreCache* is set to true, or is left empty.

#### bool datastore:SetAsync(string *key*, Variant *value*)
Posts the JSON encoded return of value to the remote datastore.
