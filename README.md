A simple site to test the use of [JSData](www.js-data.io/), [Angular](angularjs.org/), [Node](nodejs.org) together as a full-stack solution.


### What is JS-Data?

JSData is a library which provides a flexible model layer for either client or server JavaScript-based applications.  It can be used with a wide variety data sources including: RESTful services, relational databases, HTTP local storage, and a bunch of NoSQL databases.  It understands relationships between models, gives you ways to integrate business logic into models, and provides a robust local cache.  Finally, it also has a easy API which makes a clear distinction between synchronous (i.e., local) operations and asynchronous (i.e., remote) operations.

[Watch a 30min presentation by the creator of JSData](https://www.youtube.com/watch?v=8wxnnJA9FKw)

### Gotchas

A big part of this project was to gain some practical experience and run into all the little issues you have when trying to set something up for the first time, and to make sure that JS-Data can be incorporated into a real system without any awful code required to make it work.  In the process of doing so, here's a list of surprises I ran into:

* You have to jump through some hoops to make sure a `Promise` constructor is attached to the global namespace (i.e., `window` or `global`) before initializing JS-Data.  On the client, `js-data-angular` does this for you, but on the server side, you need to manage it yourself.
* The documentation for the js-data-sql adapter doesn't mention that you can add a a 'database' config setting along with the host/port/user/password.
* The documentation for the `defineResource` method doesn't mention that you can add a 'table' property to a resource definition if your table isn't named the same thing as the resource (e.g., the resource is singular, but the table is plural).
* When defining services for the client, Angular doesn't create the services automatically, so if you register a Resource as part of a service, you'll later need to force those services to be instantiated manually since JSData won't do this for you. Instead, when it attempts to resolve a relation, it will complain of a missing Resource.
* JSData doesn't provide a way to get a count of resources without actually fetching them all and counting the result.  However, using a `<module>.run` method, you can add a function to `DS.defaults` which will then appear on each Resource object.  So, if you add a `count` method to `DS.defaults`, each of your Resource services will have a `count` method along side the `find`, `findAll`, etc.
    * However... when adding such functions, you need to use the adapter directly, so unless what you want to do is possible using the standard js-data Resource methods, you'll need to create adapter-specific versions of your code.
* Adding a `$watch` on a Resource object won't get triggered when its relations are resolved. Instead, you need to set the watch after you've loaded the relations.
* When fetching a collection of Resources, it's not possible to return any meta-data about the collection (e.g., offset, limit, total).  This means you need at least one more request to support paging (i.e., the total).
* The documentation is confusing about what properties you should use when defining relations. You really nee three things:
    * localField: the property name of the fully-instantiated relation (or array). (e.g, `foo`)
    * localKey: the property containing the foreign key on the Resource (e.g., `foo_id`)
    * foreignKey: the key on the target Resource which should match the `localKey` (e.g., `id`)
* The documentation isn't very clear about what properties you can include when calling the `findAll` method when using the SQL adapter. The underlying library is [Knex.js](http://knexjs.org/), and it's documentation lays out the possibilities pretty well.
* It doesn't work to try to `JSON.stringify` resources. You need to add your own `toJSON` method or the equivalent.
* There doesn't appear to be any way to look up a resource constructor once you've created it.  Thus, you need to stash the result of calling `defineResource` somewhere so that your code can use it to access those resources.
* The use of the cache is different between the web and server environments.  In particular, the server, by default, has the cache turned off (to avoid problems with multiple workers). This comes up whenever you perform an operation which implicitly uses a cached version (e.g., `store.save()`).
