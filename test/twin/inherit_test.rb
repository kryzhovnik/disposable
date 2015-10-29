require "test_helper"

class InheritTest < MiniTest::Spec
  module Model
    Song  = Struct.new(:title, :album)
    Album = Struct.new(:name, :songs, :artist)
    Artist = Struct.new(:name)
  end

  module Twin
    class Album < Disposable::Twin
      feature Setup

      property :name, fromage: :_name

      collection :songs do
        property :name
      end

      property :artist do
        property :name

        def artist_id
          1
        end
      end
    end

    class EmptyCompilation < Album
    end

    class Compilation < Album
      property :name, writeable: false, inherit: true

      property :artist, inherit: true do

      end
    end
  end

  # definitions are not shared.
  it do
    Twin::Album.definitions.get(:name).extend(Declarative::Inspect).inspect.must_equal "#<Disposable::Twin::Definition: @options={:fromage=>:_name, :private_name=>:name, :nested=>nil, :name=>\"name\"}>"
    Twin::Compilation.definitions.get(:name).extend(Declarative::Inspect).inspect.must_equal "#<Disposable::Twin::Definition: @options={:fromage=>:_name, :private_name=>:name, :nested=>nil, :name=>\"name\", :writeable=>false}>" # FIXME: where did :inherit go?
  end


  let (:album) { Model::Album.new("In The Meantime And Inbetween Time", [], Model::Artist.new) }

  it { Twin::Album.new(album).artist.artist_id.must_equal 1 }

  # inherit inline twins when not overriding.
  it { Twin::EmptyCompilation.new(album).artist.artist_id.must_equal 1 }

  # inherit inline twins when overriding.
  it { Twin::Compilation.new(album).artist.artist_id.must_equal 1 }
end