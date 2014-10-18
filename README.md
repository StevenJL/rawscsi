# Rawscsi

[![Build Status](https://travis-ci.org/StevenJL/rawscsi.svg)](https://travis-ci.org/StevenJL/rawscsi)
[![Code Climate](https://codeclimate.com/github/StevenJL/rawscsi/badges/gpa.svg)](https://codeclimate.com/github/StevenJL/rawscsi)

Ruby Amazon Web Services Cloud Search Interface (Rawscsi) is a flexible gem for searching and indexing AWS Cloud Search with the following characteristics:

1) Maximal Flexibility: Rawscsi can construct very complex queries.  For example, using Cloud Search's default movies search domain, Rawscsi can find the top three James Bond movies excluding 'Casino', staring either 'Connery', 'Craig', or 'Moore', but not 'Brosnan', released after 1970. This is how `rawscsi` would construct this query:

```ruby
search_object.search(q: {
                          and: [
                                 { plot: "James Bond" }, 
                                 { not: { 
                                          title: "Casino"
                                        },
                                 },
                                 { or: [
                                         { actor: "Connery" },
                                         { actor: "Craig" },
                                         { actor: "Moore"}
                                       ]
                                 },
                                 { not: {
                                          actor: "Brosnan"
                                        }
                                 }]
                         },
                      date: {release_date: "[1970-01-01,}"},
                      sort: "rating desc",
                      limit: 3
                    )
```
In theory, if the query is allowed on Cloudsearch, this gem can construct it.

2) Supports Cloud Search Version api 2013-01-01.

3) Smart indexing of data to a search domain. Namely, it calculates the size of your batch and breaks it up into chunks, each of which is less than 5Mb (the upload limit).

4) Has some nice Active Record integration features.

5) Supports Ruby 1.8.7, 1.9.3, 2.0.0, 2.1.0, and 2.1.2

Here's the official aws cloud search documentation: http://docs.aws.amazon.com/cloudsearch/latest/developerguide/what-is-cloudsearch.html

## Installation

Add this line to your application's Gemfile:

    gem 'rawscsi'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rawscsi

### Registering Search Domains 

Suppose we have two search domains: Songs and Books.  Let's say Song is an `active_record` model in our project. We first register them to `Rawscsi`.

```ruby
Rawscsi.register 'Song' do |config|
  config.domain_name = 'good-songs'
  config.domain_id = 'akldfjakljf3894fjeaf9df'
  config.region = 'us-east-1'
  config.api_version = '2013-01-01' # rawscsi only supports api version 2013-01-01
  config.attributes = [:title, :album, :artist, :release_date] # since Song is an active model, we can specify the attributes we want indexed
end

Rawscsi.register 'Book' do |config|
  config.name = 'good-books'
  config.id = 'dj43g6i77dof86lk34fsf2s'
  config.region = 'us-east-1'
  config.api_version = '2013-01-01' # rawscsi only supports api version 2013-01-01
end
```

### Uploading indices
```ruby
song_indexer = Rawscsi::Index.new('Song', :active_record => true)
# Since Song is an active record object and we specified the attributes in the config, we can use the active record option
# Then we can just upload active record objects directly. Note this will use the active record id as the cloud search record id.
song_indexer.upload([
  # active record objects
  <id: 4567, title: "Saturdays Reprise", artist: "Cut Copy", album: "Bright Like Neon Love">
  <id: 5456, title: "Common Burn", artist: "Mazzy Star", album: "Seasons of Your Day">
  <id: 5346, title: "Honey Power", artist: "My Bloody Valentine">
  <id: 5762, title: "Introduction", artist: "Nick Drake">
])

book_indexer = Rawscsi::Index.new('Book')
# since Book is not an active record object, we upload hashes instead
# Note the id key in the hash  will be used as the cloud search record id.
book_indexer.upload([
  {id: 1234, title: "Surely you're Joking, Mr. Feynman", author: "Richard Feynman"},
  {id: 5546, title: "Zen and the Art of Motorcycle Maintanence", author: "Robert Pirsig"}
])
```

### Deleting indices
```ruby
song_indexer.delete([3244, 53452, 5435, 64545, 34342, 4545])
# To delete records in the search domain, you just pass an array of ids (the cloud search record id)
```

##### Automatically Batches on cloud search's 5Mb Upload Limit 
Rawscsi is smart enough to break up large batch uploads into chunks of 5 Mb (cloud search's upload size limit per post request).

### Searching
Instantiate a search object

```ruby
book_search_helper = Rawscsi::Search.new('Book')

song_search_helper = Rawscsi::Search.new('Song', :active_record => true)
# use the 'active record' option if 'Song' is a Active Record model in your project.
# Calling search will return an array of active record objects ordered by cloud search's rank score.
```

#### Simple Search
Simple search queries take one string as an argument and searches all text and text-array fields on the search domain.

```ruby
search_books_helper.search('Richard Feynman')
  => [{id: 546, author: "Richard Feynman"  title: "Surely, You're Joking Mr. Feynman" },
      {id: 657, author: "Richard Feynman", title: "What Do You Care What Other People Think"}]

search_songs_helper.search('Air')
# since we initiated this search helper with the active record option
# it returns an array of active record objects
  => [<Song id:156, artist: "White Stripes", title: "The Air Near My Fingers">,
      <Song id:342, artist: "Air", title: "Mer du Japon">]
```
#### Compound Boolean Searches
Compound search queries are queries consisting of multiple constraints, linked together by either `and` or `or` or some combination of the two. Rawscsi's philosophy in this aspect is maximal flexibility: Any query that is possible on cloud search, should be possible to construct in Rawscsi.

Lets look at some sample compound boolean queries.

```ruby
search_songs_helper.search(q: {
                                and: [{artist: "Daft Punk"}]
                              }
                           )
# Even though we're searching only one term, it's not a simple query because we're looking
# at just the artist field, not all text fields. Also note, even though its only one constrainst, we still use 'and'.
```

```ruby
search_songs_helper.search(q: {
                                and: [{ title: 'Angel' }, { artist: 'Smith' }]
                              })
# Conjunction of two constraints is done using the `and` key
=> [{song_id: 12345, title: "Angel in the Snow", artist: "Elliot Smith"},
    {song_id: 43534, title: "Angel, Angel Down We Go Together", artist: "The Smiths"}]
```
By default, the search returns all the fields in the domain.  But you can specify which fields to return. 

```ruby
search_songs.search(q: {and: [ {artist: "Cold Play"} ], 
                    fields: [:title])

=> [{ title: "Warning Sign"},
    { title: "God Put a Smile Upon Your Face"},
    { title: "Sparks"}]

```
The default sort order is Amazon Cloudsearch's rank-score but you can use your own sort as well as a limiting the number of results.
```ruby
search_songs.search(q: {and: [{genres: "Rock"}]}, sort: "rating desc", limit: 100)
# Top 100 Rock songs.
```

Here is an example of using a date constraint in conjunction ("and")  with other constraints:
```ruby
search_songs.search(q: {
                         and: [
                                { genres: "Hip Hop" }, 
                                { title: "Street"}
                               ]
                         },
                    date: { release_date: "[1995-01-01,}"}
                    limit: 5,
                    sort: "rating desc"
                   ) 
# Conjunction of two constraints and date constraint (Top 5 Hip Hop songs with Street in title released after 1995)
# Note date syntax is working in conjunction (and) with the frist two constraints. This is always the case.
# Also note syntax for searching date ranges: "[1995-01-01,}" is all dates after Jan 1 1995 while "{,1995-01-01]" is all dates before.
# Note we're limiting only 5 results and sorting by rating in descending order.
=> [{song_id: 54642, title: "Street Dreams", artist: "Nas"},
    {song_id: 98786, title: "Street Struck", artist: "Big L"},
    {song_id: 54645, title: "Street Disputes", artist: "Wu-Tang Clan"},
    {song_id: 54542, title: "Streets is Watching", artist: "Jay-Z"},
    {song_id: 54644, title: "Street Corners", artist: "Wu-Tang Clan"}]
```

So far, we've only seen 'and' examples.  Now let's look at some 'or' examples. 

```ruby
search_songs.search(q: {
                         or: [
                               { artist: "Digitalism"},
                               { artist: "Daft Punk"}, 
                               { artist: "Justice"}
                             ]
                        }
                    )
# Find the union of all the songs by these awesome electro-house bands
```
```ruby
# you can also combine `and` and `or` constraints
search_songs.search(q: {
                          and: [
                                  { range: "rating:['9',}"}, 
                                  { or: [
                                          { artist: "Bob Dylan" },
                                          { artist: "Lorde"}
                                        ]
                                  }
                                ]
                         }
                     )
# You only want highly rated songs by either Bob Dylan or Lorde (cuz you know, Lorde is the new Bob Dylan)
```

And of course, negation:

```ruby
# You love the song "All Along the Watchtower" but you didn't like the Dave Matthews Band cover 
search_songs.search(q: {
                         and: [ 
                                { title: "All Along the Watchtower"},
                                  not: {
                                          artist: "Dave Matthews Band"
                                       }
                              ]
                        }
                    )
```

By default, the search returns all the fields in the domain.  But you can specify which fields to return. 

```ruby
search_songs.search(q: {and: [ {artist: "Cold Play"} ], 
                    fields: [:title])

=> [{ title: "Warning Sign"},
    { title: "God Put a Smile Upon Your Face"},
    { title: "Sparks"}]

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

(The MIT License)

Copyright © 2014 Steven Li

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
‘Software’), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

