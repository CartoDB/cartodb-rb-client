require 'spec_helper'

describe 'CartoDB model data methods' do

  it "should initialize attributes of the model without persisting them into cartodb using the `new` method" do

    losail_circuit = new_circuit

    # expects{ CartoDB::Connection.records 'moto_gp_circuit' }.to raise_error(CartoDB::Client:Error, /404 - Not found/)
    records = CartoDB::Connection.records 'moto_gp_circuit'
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
    }.to change{CartoDB::Connection.records('moto_gp_circuit').total_rows}.from(0).to(1)
    record = CartoDB::Connection.row 'moto_gp_circuit', losail_circuit.cartodb_id
    record.cartodb_id.should             be == 1
    record.name.should             be == 'Losail Circuit'
    record.description.should      match /The fabulous Losail International Circuit lies/
    record.latitude.should         be == 25.488840
    record.longitude.should        be == 51.453352
    record.length.should           be == '5380m'
    record.width.should            be == '12m'
    record.left_corners.should     be == 6
    record.right_corners.should    be == 10
    record.longest_straight.should be == '1068m'
    record.constructed.should be == Date.new(2004, 1, 1)
    record.modified.should    be == Date.new(2004, 1, 1)

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

    record = CartoDB::Connection.row 'moto_gp_circuit', losail_circuit.cartodb_id
    record.cartodb_id.should             be == 1
    record.name.should             be == 'Losail Circuit'
    record.description.should      match /The fabulous Losail International Circuit lies/
    record.latitude.should         be == 25.488840
    record.longitude.should        be == 51.453352
    record.length.should           be == '5380m'
    record.width.should            be == '12m'
    record.left_corners.should     be == 6
    record.right_corners.should    be == 10
    record.longest_straight.should be == '1068m'
    record.constructed.should be == Date.new(2004, 1, 1)
    record.modified.should    be == Date.new(2004, 1, 1)

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
    }.to change{CartoDB::Connection.records('moto_gp_circuit').total_rows}.by(0)


    record = CartoDB::Connection.row 'moto_gp_circuit', losail_circuit.cartodb_id
    record.cartodb_id.should       be == 1
    record.name.should             be == 'Prueba'
    record.description.should      match /Lorem ipsum dolor sit amet, consectetur adipisicing elit/
    record.latitude.should         be == 40.582394
    record.longitude.should        be == -3.994131
    record.length.should           be == '1243m'

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
    }.to change{CartoDB::Connection.records('moto_gp_circuit').total_rows}.by(-1)

  end

end
