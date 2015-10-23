# What is JSData

![system diagram](system_diagram.png)

# Demo App

1. paging support easy to add (but not automatic)
2. relations are fully supported
3. angular selects are easy and use locally cached lists
4. updates are reflected to the one shared model in real time
    * tricky to work around this, actually
5. API to revert unsaved changes
6. API to save changes


# Code Walkthrough

1. Server Side
    1. set up JSData store (server.coffee / server_schema.coffee)
    2. define models (composers.coffee / works.coffee)
    3. using the model (routes.coffee)
2. Client Side
    1. set up the JSData store (client.coffee / client_schema.coffee)
    2. define models (same as server!)
    3. base controllers (base_controllers.coffee / composer.coffee)
    4. editing models (editor.coffee / work.coffee)

# Pros & Cons

* Pros:
    1. There is only one instance of each model object.
    2. There is a simple, unified way to get model instances (including relations).
    3. Business logic, validations, and computed fields can easily be attached to models.
    4. JSData comes with robust support for Angular environments.
* Cons:
    1. The built-in HTTP adapter has baked-in assumptions about how endpoints work. We may need to change some of our endpoints to accomodate this or work around the HTTP adapter.
    2. The "one instance per model" paradigm makes our current dialog behavior awkward to implement exactly (though a robust alternative is available).

# Questions

1. Do you need to save each model individually, or do parents save children automatically?

    When saving a graph of models, each model must be saved individually.

2. Can you make a copy of a model which isn't the one canonical instance?

    You can copy individual fields out of a model into a new object, but JSData is specifically designed to not allow multiple copies of a model to exist.
