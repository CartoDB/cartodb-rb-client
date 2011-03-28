require 'spec_helper'
require 'cartodb-rb-client/cartodb/model'

describe 'CartoDB model' do
  it "should have a valid CartoDB::Client instance as a connection object" do
    model = MotoGPCircuit.new
    model.connection.should_not be_nil
    model.connection.should be_a CartoDB::Client::Connection
    table = model.connection.create_table 'model_connection_test'
    table.should_not be_nil
    table[:id].should be > 0
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

  it "should initialize attributes of the model without persisting them into cartodb using the `new` method" do
    losail_circuit = new_circuit

    # expects{ @cartodb.records 'moto_gp_circuit' }.to raise_error(CartoDB::Client:Error, /404 - Not found/)
    records = @cartodb.records 'moto_gp_circuit'
    records.total_rows.should == 0
    records.rows.should be_empty

    losail_circuit.name.should be == 'Losail Circuit'
    losail_circuit.description.should be == 'The fabulous Losail International Circuit lies on the outskirts of Doha, the capital city of Qatar. Built in little over a year, the track cost $58 million USD and required round-the-clock dedication from almost 1,000 workers in order to get it ready for the inaugural event - the Marlboro Grand Prix of Qatar on the 2nd October 2004.'
    losail_circuit.latitude.should be == 25.488840
    losail_circuit.longitude.should be == 51.453352
    losail_circuit.length.should be == '5380m'
    losail_circuit.width.should be == '12m'
    losail_circuit.left_corners.should be == 6
    losail_circuit.right_corners.should be == 10
    losail_circuit.longest_straight.should be == '1068m'
    losail_circuit.constructed.should be == Date.new(2004, 1, 1)
    losail_circuit.modified.should be == Date.new(2004, 1, 1)
  end

  it "should persist into cartodb using the save method" do
    losail_circuit = new_circuit

     expect {
      losail_circuit.save.should be_true
    }.to change{@cartodb.records('moto_gp_circuit').total_rows}.from(0).to(1)

    record = @cartodb.row 'moto_gp_circuit', losail_circuit.cartodb_id
    record[:cartodb_id].should             be == 1
    record[:name].should             be == 'Losail Circuit'
    record[:description].should      match /The fabulous Losail International Circuit lies/
    record[:latitude].should         be == 25.488840
    record[:longitude].should        be == 51.453352
    record[:length].should           be == '5380m'
    record[:width].should            be == '12m'
    record[:left_corners].should     be == 6
    record[:right_corners].should    be == 10
    record[:longest_straight].should be == '1068m'
    record[:constructed].should      be == Date.new(2004, 1, 1).strftime("%Y-%m-%d %H:%M:%S")
    record[:modified].should         be == Date.new(2004, 1, 1).strftime("%Y-%m-%d %H:%M:%S")

    losail_circuit.cartodb_id.should be == 1
    losail_circuit.name.should be == 'Losail Circuit'
    losail_circuit.description.should be == 'The fabulous Losail International Circuit lies on the outskirts of Doha, the capital city of Qatar. Built in little over a year, the track cost $58 million USD and required round-the-clock dedication from almost 1,000 workers in order to get it ready for the inaugural event - the Marlboro Grand Prix of Qatar on the 2nd October 2004.'
    losail_circuit.latitude.should be == 25.488840
    losail_circuit.longitude.should be == 51.453352
    losail_circuit.length.should be == '5380m'
    losail_circuit.width.should be == '12m'
    losail_circuit.left_corners.should be == 6
    losail_circuit.right_corners.should be == 10
    losail_circuit.longest_straight.should be == '1068m'
    losail_circuit.constructed.should be == Date.new(2004, 1, 1)
    losail_circuit.modified.should be == Date.new(2004, 1, 1)
  end

  it "should persist into cartodb using the static create method" do
    losail_circuit = MotoGPCircuit.create new_losail_circuit_attributes

    record = @cartodb.row 'moto_gp_circuit', losail_circuit.cartodb_id
    record[:cartodb_id].should             be == 1
    record[:name].should             be == 'Losail Circuit'
    record[:description].should      match /The fabulous Losail International Circuit lies/
    record[:latitude].should         be == 25.488840
    record[:longitude].should        be == 51.453352
    record[:length].should           be == '5380m'
    record[:width].should            be == '12m'
    record[:left_corners].should     be == 6
    record[:right_corners].should    be == 10
    record[:longest_straight].should be == '1068m'
    record[:constructed].should      be == Date.new(2004, 1, 1).strftime("%Y-%m-%d %H:%M:%S")
    record[:modified].should         be == Date.new(2004, 1, 1).strftime("%Y-%m-%d %H:%M:%S")

    losail_circuit.cartodb_id.should be == 1
    losail_circuit.name.should be == 'Losail Circuit'
    losail_circuit.description.should be == 'The fabulous Losail International Circuit lies on the outskirts of Doha, the capital city of Qatar. Built in little over a year, the track cost $58 million USD and required round-the-clock dedication from almost 1,000 workers in order to get it ready for the inaugural event - the Marlboro Grand Prix of Qatar on the 2nd October 2004.'
    losail_circuit.latitude.should be == 25.488840
    losail_circuit.longitude.should be == 51.453352
    losail_circuit.length.should be == '5380m'
    losail_circuit.width.should be == '12m'
    losail_circuit.left_corners.should be == 6
    losail_circuit.right_corners.should be == 10
    losail_circuit.longest_straight.should be == '1068m'
    losail_circuit.constructed.should be == Date.new(2004, 1, 1)
    losail_circuit.modified.should be == Date.new(2004, 1, 1)
  end

  it "should update an existing record" do
    losail_circuit = MotoGPCircuit.create new_losail_circuit_attributes

    losail_circuit.name = 'Prueba'
    losail_circuit.description = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
    losail_circuit.latitude = 40.582394
    losail_circuit.longitude = -3.994131
    losail_circuit.length = '1243m'

     expect {
      losail_circuit.save
    }.to change{@cartodb.records('moto_gp_circuit').total_rows}.by(0)


    record = @cartodb.row 'moto_gp_circuit', losail_circuit.cartodb_id
    record[:cartodb_id].should       be == 1
    record[:name].should             be == 'Prueba'
    record[:description].should      match /Lorem ipsum dolor sit amet, consectetur adipisicing elit/
    record[:latitude].should         be == 40.582394
    record[:longitude].should        be == -3.994131
    record[:length].should           be == '1243m'

    losail_circuit.name.should be == 'Prueba'
    losail_circuit.description.should match /Lorem ipsum dolor sit amet, consectetur adipisicing elit/
    losail_circuit.latitude.should be == 40.582394
    losail_circuit.longitude.should be == -3.994131
    losail_circuit.length.should be == '1243m'
  end

  it "should destroy a previously created record" do
    losail_circuit = MotoGPCircuit.create new_losail_circuit_attributes

     expect {
      losail_circuit.destroy
    }.to change{@cartodb.records('moto_gp_circuit').total_rows}.by(-1)

  end

  it "should return all records paginated" do
    create_random_circuits(20)

    circuits = MotoGPCircuit.all

    circuits.should have(10).circuits
    circuits.first.should be_a_kind_of(MotoGPCircuit)
    circuits.first.cartodb_id.should be == 1
    circuits.first.name.should be == 'circuit #1'
    circuits.first.description.should be == 'awesome circuit #1'
    circuits.first.latitude.should be == 25.488840
    circuits.first.longitude.should be == 51.453352
    circuits.first.length.should be == '5380m'
    circuits.first.width.should be == '12m'
    circuits.first.left_corners.should be == 6
    circuits.first.right_corners.should be == 10
    circuits.first.longest_straight.should be == '1068m'
    circuits.first.constructed.should be == Date.new(2004, 1, 1).strftime("%Y-%m-%d %H:%M:%S")
    circuits.first.modified.should be == Date.new(2004, 1, 1).strftime("%Y-%m-%d %H:%M:%S")
  end

  it "should count all records" do
    create_random_circuits(20)

    MotoGPCircuit.count.should be == 20

    create_random_circuit

    MotoGPCircuit.count.should be == 21
  end

  it "should find a record by its id" do
    create_random_circuit

    circuit = MotoGPCircuit.where(:cartodb_id => 1)

    circuit.cartodb_id.should be == 1
    circuit.name.should be == 'circuit #1'
    circuit.description.should be == 'awesome circuit #1'
    circuit.latitude.should be == 25.488840
    circuit.longitude.should be == 51.453352
    circuit.length.should be == '5380m'
    circuit.width.should be == '12m'
    circuit.left_corners.should be == 6
    circuit.right_corners.should be == 10
    circuit.longest_straight.should be == '1068m'
    circuit.constructed.should be == Date.new(2004, 1, 1).strftime("%Y-%m-%d %H:%M:%S")
    circuit.modified.should be == Date.new(2004, 1, 1).strftime("%Y-%m-%d %H:%M:%S")

    same_circuit = MotoGPCircuit.find(1)

    same_circuit.cartodb_id.should be == 1
    same_circuit.name.should be == 'circuit #1'
    same_circuit.description.should be == 'awesome circuit #1'
    same_circuit.latitude.should be == 25.488840
    same_circuit.longitude.should be == 51.453352
    same_circuit.length.should be == '5380m'
    same_circuit.width.should be == '12m'
    same_circuit.left_corners.should be == 6
    same_circuit.right_corners.should be == 10
    same_circuit.longest_straight.should be == '1068m'
    same_circuit.constructed.should be == Date.new(2004, 1, 1).strftime("%Y-%m-%d %H:%M:%S")
    same_circuit.modified.should be == Date.new(2004, 1, 1).strftime("%Y-%m-%d %H:%M:%S")
  end

  it "should search records by certain filters" do
    new_circuit(:name => 'Losail circuit',       :left_corners => 6, :right_corners => 10).save
    new_circuit(:name => 'Jerez',                :left_corners => 5, :right_corners => 8).save
    new_circuit(:name => 'Estoril',              :left_corners => 4, :right_corners => 9).save
    new_circuit(:name => 'Lemans',               :left_corners => 4, :right_corners => 9).save
    new_circuit(:name => 'Circuit de Catalunya', :left_corners => 5, :right_corners => 8).save

    circuits = MotoGPCircuit.where(:left_corners => 4, :right_corners => 9)

    circuits.should have(2).circuits
    circuits.first.name.should be == 'Estoril'
    circuits.last.name.should be == 'Lemans'

    circuits = MotoGPCircuit.where("left_corners = ? AND right_corners = ?", 4, 9)

    circuits.should have(2).circuits
    circuits.first.name.should be == 'Estoril'
    circuits.last.name.should be == 'Lemans'
  end

end
