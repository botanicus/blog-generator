# About

[![Build Status](https://travis-ci.org/botanicus/blog-generator.svg?branch=master)](https://travis-ci.org/botanicus/blog-generator)

Few years back we used to use all the fancy static site generators for building a blog, so the blog could have layouts, tags, pagination and other features. With the arrival of frontend frameworks such as AngularJS, this is no longer necessary.

We can generate a static JSON API and let AngularJS handle the rest.

# Usage

gem install blog-generator
gem install redcarpet # If you are going to use markdown.
mkdir botanicus.me
cd botanicus.me
mkdir posts
blog-generator.rb posts api

# Post structure

```html
title: 'Hello world!'
tags: ['Hello world', 'Test']
---

<p id="excerpt">
  Excerpt
</p>


<h1>Hello world!</h1>
<p>
  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Soluta quibusdam necessitatibus tempore ullam incidunt amet omnis, veritatis dicta quisquam accusamus at provident vel facere corporis sed fugiat cumque. Consequuntur, necessitatibus!
</p>
```

## Assumptions

- Metadata `title` and optionally `tags`.
- Metadata `draft: true` will exclude the post.
- Any other metadata can be added and will be accessible in the resulting JSON.
- Body has `#excerpt`.
- Format `posts/:published_at-:slug.:format`.

# Routes generated

- `slug` and `published_at` added to metadata.
- `/metadata.json`
- `/posts.json`
- `/posts/:slug.json`
- `/tags.json`
- `/tags/:slug.json`

# Status

It works, but it needs polishing.

# TODO

- Generate assets by parsing the document, no explicit spec.
- GH markdown including source code support.
