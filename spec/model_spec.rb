require 'spec_helper'
require 'cartodb-rb-client/cartodb/model'

describe 'CartoDB model' do
  it "should have a valid CartoDB::Client instance as a connection object" do
    model = MotoGPCircuit.new
    model.connection.should_not be_nil
    model.connection.should be_a CartoDB::Client
    table = model.connection.create_table 'model_connection_test'
    table.should_not be_nil
    table.id.should be > 0
    table.name.should be == 'model_connection_test'
  end

  it "should have a valid table name" do
    model = MotoGPCircuit.new
    model.table_name.should be == 'moto_gp_circuit'
  end

  it "should create the table in cartodb if it doesn't exists" do
    model = MotoGPCircuit.new

    model.cartodb_table_exists?.should be_true
  end

  it "should contain an array of columns" do
    model = MotoGPCircuit.new

    model.columns.should_not be_nil
    model.columns.should have(14).items
    model.columns.should include({:name => 'cartodb_id',       :type => 'number'})
    model.columns.should include({:name => 'name',             :type => 'string'})
    model.columns.should include({:name => 'description',      :type => 'string'})
    model.columns.should include({:name => 'latitude',         :type => 'number'})
    model.columns.should include({:name => 'longitude',        :type => 'number'})
    model.columns.should include({:name => 'created_at',       :type => 'date'})
    model.columns.should include({:name => 'updated_at',       :type => 'date'})
    model.columns.should include({:name => 'length',           :type => 'string'})
    model.columns.should include({:name => 'width',            :type => 'string'})
    model.columns.should include({:name => 'left_corners',     :type => 'number'})
    model.columns.should include({:name => 'right_corners',    :type => 'number'})
    model.columns.should include({:name => 'longest_straight', :type => 'string'})
    model.columns.should include({:name => 'constructed',      :type => 'date'})
    model.columns.should include({:name => 'modified',         :type => 'date'})
  end

  it "should add more columns if the table previously exists and doesn't have all model columns" do
    table = @cartodb.create_table 'moto_gp_circuit'
    table.schema.should include(["cartodb_id", "number"])
    table.schema.should include(["name", "string"])
    table.schema.should include(["latitude", "number", "latitude"])
    table.schema.should include(["longitude", "number", "longitude"])
    table.schema.should include(["description", "string"])
    table.schema.should include(["created_at", "date"])
    table.schema.should include(["updated_at", "date"])
    table.schema.should_not include(['length', 'string'])
    table.schema.should_not include(['width','string'])
    table.schema.should_not include(['left_corners', 'number'])
    table.schema.should_not include(['right_corners', 'number'])
    table.schema.should_not include(['longest_straight', 'string'])
    table.schema.should_not include(['constructed', 'date'])
    table.schema.should_not include(['modified', 'date'])

    model = MotoGPCircuit.new

    model.columns.should_not be_nil
    model.columns.should have(14).items
    model.columns.should include({:name => 'cartodb_id',       :type => 'number'})
    model.columns.should include({:name => 'name',             :type => 'string'})
    model.columns.should include({:name => 'description',      :type => 'string'})
    model.columns.should include({:name => 'latitude',         :type => 'number'})
    model.columns.should include({:name => 'longitude',        :type => 'number'})
    model.columns.should include({:name => 'created_at',       :type => 'date'})
    model.columns.should include({:name => 'updated_at',       :type => 'date'})
    model.columns.should include({:name => 'length',           :type => 'string'})
    model.columns.should include({:name => 'width',            :type => 'string'})
    model.columns.should include({:name => 'left_corners',     :type => 'number'})
    model.columns.should include({:name => 'right_corners',    :type => 'number'})
    model.columns.should include({:name => 'longest_straight', :type => 'string'})
    model.columns.should include({:name => 'constructed',      :type => 'date'})
    model.columns.should include({:name => 'modified',         :type => 'date'})

  end

end
