require 'spec_helper'

describe Billogram::Resource do
  subject { described_class }

  describe ".build_objects" do
    subject { described_class.build_objects(argument) }

    before { allow_any_instance_of(described_class).to receive("attribute=") }

    describe "when hash given" do
      let(:argument) { {attribute: 'test'} }
      it { is_expected.to be_a(Billogram::Resource)}
    end

    describe "when array given" do
      let(:argument) { [{attribute: 'test'}, {attribute: 'test2'}] }

      it { is_expected.to be_a(Array) }

      it "returns array of instances" do
        subject.each do |item|
          expect(item).to be_a(Billogram::Resource)
        end
      end
    end

    describe "when nil given" do
      let(:argument) { nil }

      it { is_expected.to be_nil }
    end

    describe "when string given" do
      let(:argument) { "test" }

      it { is_expected.to eq("test")}
    end
  end

  describe ".relation" do
    before do
      subject.relation(:one_relation, :one)
      subject.relation(:many_relations, :many)
    end

    it "defines attr_accessors" do
      expect(subject.new).to respond_to(:one_relation)
      expect(subject.new).to respond_to(:many_relations)
    end

    it "adds relation to class variable" do
      expect(subject.relations).to include(Billogram::Relation)
    end
  end

  describe "#to_hash" do
    let(:array) { [described_class.new, described_class.new] }
    let(:resource) { described_class.new }
    let(:instance_variables) { [:@array, :@resource] }

    subject { described_class.new }

    before do
      allow(subject).to receive(:instance_variables).and_return(instance_variables)
      allow(subject).to receive(:instance_variable_get).with(:@array).and_return(array)
      allow(subject).to receive(:instance_variable_get).with(:@resource).and_return(resource)
    end

    it "calls #to_hash on a nested resource" do
      expect(resource).to receive(:to_hash)

      subject.to_hash
    end

    it "calls #to_hash on every item in array" do
      array.each do |item|
        expect(item).to receive(:to_hash)
      end

      subject.to_hash
    end
  end

  describe "unknown attribute" do
    before do
      @orig_stderr = $stderr
      $stderr = StringIO.new
    end

    it "shows warning" do
      described_class.new({key: 'test'})
      $stderr.rewind
      expect($stderr.string.chomp).to eq("Billogram::Resource: unknown attribute key")
    end

    after do
      $stderr = @orig_stderr
    end
  end
end
