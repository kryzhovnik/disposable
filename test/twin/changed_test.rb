require 'test_helper'
# require 'reform/form/coercion'

class ChangedWithSetupTest < MiniTest::Spec
  module Model
    Song  = Struct.new(:title, :length, :composer)
    Album = Struct.new(:name, :songs, :artist)
    Artist = Struct.new(:name)
  end

  require "disposable/twin/changed"
  module Twin
    class Album < Disposable::Twin
      feature Setup
      feature Changed
      # include Coercion
      property :name

      collection :songs do
        property :title
        property :length, type: Integer

        property :composer do
          property :name
        end
      end

      property :artist do
        include Setup
        property :name
      end
    end
  end


  let (:song)     { Model::Song.new("Broken") }
  let (:composer) { Model::Artist.new(2) }
  let (:song_with_composer) { Model::Song.new("Broken", 246, composer) }
  let (:artist)   { Model::Artist.new("Randy") }
  let (:album)    { Model::Album.new("The Rest Is Silence", [song, song_with_composer], artist) }
  let (:twin)     { Twin::Album.new(album) }

  # setup: changed? is always false
  it do
    twin.changed?(:name).must_equal false
    twin.changed?.must_equal false

    twin.songs[0].changed?.must_equal false
    twin.songs[0].changed?(:title).must_equal false
    twin.songs[1].changed?.must_equal false
    twin.songs[1].changed?(:title).must_equal false

    twin.songs[1].composer.changed?(:name).must_equal false
    twin.songs[1].composer.changed?.must_equal false

    twin.artist.changed?(:name).must_equal false
    twin.artist.changed?.must_equal false
  end

  # only when a property is assigned, it's changed.
  it do
    twin.name= "Out Of Bounds"
    twin.songs[0].title= "I Have Seen"
    twin.songs[1].title= "In A Rhyme"
    twin.songs[1].composer.name= "Ingemar Jansson & Mikael Danielsson"
    twin.artist.name = "No Fun At All"

    twin.changed?(:name).must_equal true
    # twin.changed?.must_equal true

    # twin.songs[0].changed?.must_equal true
    twin.songs[0].changed?(:title).must_equal true
    # twin.songs[1].changed?.must_equal true
    twin.songs[1].changed?(:title).must_equal true

    twin.songs[1].composer.changed?(:name).must_equal true
    # twin.songs[1].composer.changed?.must_equal true

    twin.artist.changed?(:name).must_equal true
    # twin.artist.changed?.must_equal true
  end

  # nested changes should propagate up.
  it do
    twin.songs[1].composer.name = "Nofx"

    # FIXME: Collection#changed?.
    # twin.songs.changed?.must_equal true
    twin.songs[1].changed?.must_equal true
    twin.songs[0].changed?.must_equal false

    twin.artist.changed?.must_equal false
    twin.changed?.must_equal true
  end
end