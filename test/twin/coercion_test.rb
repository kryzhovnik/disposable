require "test_helper"

require "disposable/twin/coercion"

class CoercionTest < MiniTest::Spec

  class TwinWithSkipSetter < Disposable::Twin
    feature Coercion
    feature Setup::SkipSetter

    property :id
    property :released_at, type: Types::Form::DateTime

    property :hit do
      property :length, type: Types::Coercible::Int
      property :good,   type: Types::Bool
    end

    property :band do
      property :label do
        property :value, type: Types::Coercible::Float
      end
    end
  end

  describe "with Setup::SkipSetter" do

    subject do
      TwinWithSkipSetter.new(album)
    end

    let (:album) {
      OpenStruct.new(
        id: 1,
        :released_at => "31/03/1981",
        :hit         => OpenStruct.new(:length => "312"),
        :band        => OpenStruct.new(:label => OpenStruct.new(:value => "9999.99"))
      )
    }

    it "NOT coerce values in setup" do
      subject.released_at.must_equal "31/03/1981"
      subject.hit.length.must_equal "312"
      subject.band.label.value.must_equal "9999.99"
    end


    it "coerce values when using a setter" do
      subject.id = Object
      subject.released_at = "30/03/1981"
      subject.hit.length = "312"
      subject.band.label.value = "9999.99"

      subject.released_at.must_be_kind_of DateTime
      subject.released_at.must_equal DateTime.parse("30/03/1981")
      subject.hit.length.must_equal 312
      subject.hit.good.must_equal nil
      subject.band.label.value.must_equal 9999.99
    end
  end

  class TwinWithoutSkipSetter < Disposable::Twin
    feature Coercion
    property :id, type: Types::Coercible::Int
  end

  describe "without Setup::SkipSetter" do

    subject do
      TwinWithoutSkipSetter.new(OpenStruct.new(id: "1"))
    end

    it "coerce values in setup and when using a setter" do
      subject.id.must_equal 1
      subject.id = "2"
      subject.id.must_equal 2
    end
  end

  class TwinWithNilify < Disposable::Twin
    feature Coercion

    property :date_of_birth,
             type: Types::Form::Date, nilify: true
    property :date_of_death_by_unicorns,
             type: Types::Form::Nil | Types::Form::Date
    property :id, nilify: true
  end

  describe "with Nilify" do

    subject do
      TwinWithNilify.new(OpenStruct.new(date_of_birth: '1990-01-12',
                                        date_of_death_by_unicorns: '2037-02-18',
                                        id: 1))
    end

    it "coerce values correctly" do
      subject.date_of_birth.must_equal Date.parse('1990-01-12')
      subject.date_of_death_by_unicorns.must_equal Date.parse('2037-02-18')
    end

    it "coerce empty values to nil when using option nilify: true" do
      subject.date_of_birth = ""
      subject.date_of_birth.must_equal nil
    end

    it "coerce empty values to nil when using dry-types | operator" do
      subject.date_of_death_by_unicorns = ""
      subject.date_of_death_by_unicorns.must_equal nil
    end

    it "converts blank string to nil, without :type option" do
      subject.id = ""
      subject.id.must_equal nil
    end
  end
end
