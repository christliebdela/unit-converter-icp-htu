import Array "mo:base/Array";
import Float "mo:base/Float";
import Text "mo:base/Text";
import Debug "mo:base/Debug";

actor UnitConverter {
  // Unit data structure
  type Unit = {
    name: Text;
    abbreviation: Text;
    toBase: Float; // Conversion factor to base unit
    fromBase: Float; // Conversion factor from base unit
    offset: Float; // For units like temperature that need an offset
  };

  // Unit definitions for each category
  let lengthUnits : [Unit] = [
    { name = "Meter"; abbreviation = "m"; toBase = 1.0; fromBase = 1.0; offset = 0.0 },
    { name = "Kilometer"; abbreviation = "km"; toBase = 1000.0; fromBase = 0.001; offset = 0.0 },
    { name = "Centimeter"; abbreviation = "cm"; toBase = 0.01; fromBase = 100.0; offset = 0.0 },
    { name = "Millimeter"; abbreviation = "mm"; toBase = 0.001; fromBase = 1000.0; offset = 0.0 },
    { name = "Inch"; abbreviation = "in"; toBase = 0.0254; fromBase = 39.3701; offset = 0.0 },
    { name = "Foot"; abbreviation = "ft"; toBase = 0.3048; fromBase = 3.28084; offset = 0.0 },
    { name = "Yard"; abbreviation = "yd"; toBase = 0.9144; fromBase = 1.09361; offset = 0.0 },
    { name = "Mile"; abbreviation = "mi"; toBase = 1609.34; fromBase = 0.000621371; offset = 0.0 },
  ];

  let massUnits : [Unit] = [
    { name = "Kilogram"; abbreviation = "kg"; toBase = 1.0; fromBase = 1.0; offset = 0.0 },
    { name = "Gram"; abbreviation = "g"; toBase = 0.001; fromBase = 1000.0; offset = 0.0 },
    { name = "Milligram"; abbreviation = "mg"; toBase = 0.000001; fromBase = 1000000.0; offset = 0.0 },
    { name = "Pound"; abbreviation = "lb"; toBase = 0.453592; fromBase = 2.20462; offset = 0.0 },
    { name = "Ounce"; abbreviation = "oz"; toBase = 0.0283495; fromBase = 35.274; offset = 0.0 },
    { name = "Ton"; abbreviation = "t"; toBase = 1000.0; fromBase = 0.001; offset = 0.0 },
  ];

  let temperatureUnits : [Unit] = [
    { name = "Celsius"; abbreviation = "°C"; toBase = 1.0; fromBase = 1.0; offset = 0.0 },
    { name = "Fahrenheit"; abbreviation = "°F"; toBase = 1.0; fromBase = 1.0; offset = 0.0 }, // Special conversion needed
    { name = "Kelvin"; abbreviation = "K"; toBase = 1.0; fromBase = 1.0; offset = 273.15 },
  ];

  let timeUnits : [Unit] = [
    { name = "Second"; abbreviation = "s"; toBase = 1.0; fromBase = 1.0; offset = 0.0 },
    { name = "Minute"; abbreviation = "min"; toBase = 60.0; fromBase = 1.0/60.0; offset = 0.0 },
    { name = "Hour"; abbreviation = "h"; toBase = 3600.0; fromBase = 1.0/3600.0; offset = 0.0 },
    { name = "Day"; abbreviation = "d"; toBase = 86400.0; fromBase = 1.0/86400.0; offset = 0.0 },
    { name = "Week"; abbreviation = "wk"; toBase = 604800.0; fromBase = 1.0/604800.0; offset = 0.0 },
  ];

  let speedUnits : [Unit] = [
    { name = "Meters per second"; abbreviation = "m/s"; toBase = 1.0; fromBase = 1.0; offset = 0.0 },
    { name = "Kilometers per hour"; abbreviation = "km/h"; toBase = 0.277778; fromBase = 3.6; offset = 0.0 },
    { name = "Miles per hour"; abbreviation = "mph"; toBase = 0.44704; fromBase = 2.23694; offset = 0.0 },
    { name = "Feet per second"; abbreviation = "ft/s"; toBase = 0.3048; fromBase = 3.28084; offset = 0.0 },
    { name = "Knot"; abbreviation = "kn"; toBase = 0.514444; fromBase = 1.94384; offset = 0.0 },
  ];

  let areaUnits : [Unit] = [
    { name = "Square meter"; abbreviation = "m²"; toBase = 1.0; fromBase = 1.0; offset = 0.0 },
    { name = "Square kilometer"; abbreviation = "km²"; toBase = 1000000.0; fromBase = 0.000001; offset = 0.0 },
    { name = "Square centimeter"; abbreviation = "cm²"; toBase = 0.0001; fromBase = 10000.0; offset = 0.0 },
    { name = "Square foot"; abbreviation = "ft²"; toBase = 0.092903; fromBase = 10.7639; offset = 0.0 },
    { name = "Acre"; abbreviation = "ac"; toBase = 4046.86; fromBase = 0.000247105; offset = 0.0 },
    { name = "Hectare"; abbreviation = "ha"; toBase = 10000.0; fromBase = 0.0001; offset = 0.0 },
  ];

  let volumeUnits : [Unit] = [
    { name = "Cubic meter"; abbreviation = "m³"; toBase = 1.0; fromBase = 1.0; offset = 0.0 },
    { name = "Liter"; abbreviation = "L"; toBase = 0.001; fromBase = 1000.0; offset = 0.0 },
    { name = "Milliliter"; abbreviation = "mL"; toBase = 0.000001; fromBase = 1000000.0; offset = 0.0 },
    { name = "Gallon (US)"; abbreviation = "gal"; toBase = 0.00378541; fromBase = 264.172; offset = 0.0 },
    { name = "Fluid ounce (US)"; abbreviation = "fl oz"; toBase = 0.0000295735; fromBase = 33814.0; offset = 0.0 },
  ];

  let energyUnits : [Unit] = [
    { name = "Joule"; abbreviation = "J"; toBase = 1.0; fromBase = 1.0; offset = 0.0 },
    { name = "Kilojoule"; abbreviation = "kJ"; toBase = 1000.0; fromBase = 0.001; offset = 0.0 },
    { name = "Calorie"; abbreviation = "cal"; toBase = 4.184; fromBase = 0.239006; offset = 0.0 },
    { name = "Kilocalorie"; abbreviation = "kcal"; toBase = 4184.0; fromBase = 0.000239006; offset = 0.0 },
    { name = "Watt-hour"; abbreviation = "Wh"; toBase = 3600.0; fromBase = 0.000277778; offset = 0.0 },
    { name = "Kilowatt-hour"; abbreviation = "kWh"; toBase = 3600000.0; fromBase = 2.77778e-7; offset = 0.0 },
  ];

  let pressureUnits : [Unit] = [
    { name = "Pascal"; abbreviation = "Pa"; toBase = 1.0; fromBase = 1.0; offset = 0.0 },
    { name = "Kilopascal"; abbreviation = "kPa"; toBase = 1000.0; fromBase = 0.001; offset = 0.0 },
    { name = "Bar"; abbreviation = "bar"; toBase = 100000.0; fromBase = 0.00001; offset = 0.0 },
    { name = "Atmosphere"; abbreviation = "atm"; toBase = 101325.0; fromBase = 9.86923e-6; offset = 0.0 },
    { name = "Pound per square inch"; abbreviation = "psi"; toBase = 6894.76; fromBase = 0.000145038; offset = 0.0 },
  ];

  // Function to get all unit categories
  public query func getUnitCategories() : async [Text] {
    return ["Length", "Mass", "Temperature", "Time", "Speed", "Area", "Volume", "Energy", "Pressure"];
  };

  // Function to get units for a specific category
  public query func getUnits(category: Text) : async [Text] {
    switch (category) {
      case "Length" { Array.map<Unit, Text>(lengthUnits, func(unit) { unit.name }) };
      case "Mass" { Array.map<Unit, Text>(massUnits, func(unit) { unit.name }) };
      case "Temperature" { Array.map<Unit, Text>(temperatureUnits, func(unit) { unit.name }) };
      case "Time" { Array.map<Unit, Text>(timeUnits, func(unit) { unit.name }) };
      case "Speed" { Array.map<Unit, Text>(speedUnits, func(unit) { unit.name }) };
      case "Area" { Array.map<Unit, Text>(areaUnits, func(unit) { unit.name }) };
      case "Volume" { Array.map<Unit, Text>(volumeUnits, func(unit) { unit.name }) };
      case "Energy" { Array.map<Unit, Text>(energyUnits, func(unit) { unit.name }) };
      case "Pressure" { Array.map<Unit, Text>(pressureUnits, func(unit) { unit.name }) };
      case _ { [] };
    };
  };

  // Helper function to find a unit in an array
  private func findUnit(units: [Unit], unitName: Text) : ?Unit {
    for (unit in units.vals()) {
      if (unit.name == unitName) {
        return ?unit;
      };
    };
    return null;
  };

  // Convert temperature (special case)
  private func convertTemperature(value: Float, fromUnit: Text, toUnit: Text) : Float {
    // Convert to Celsius (base unit) first
    var celsius : Float = 0;
    
    if (fromUnit == "Celsius") {
      celsius := value;
    } else if (fromUnit == "Fahrenheit") {
      celsius := (value - 32.0) * 5.0 / 9.0;
    } else if (fromUnit == "Kelvin") {
      celsius := value - 273.15;
    };
    
    // Convert from Celsius to target unit
    if (toUnit == "Celsius") {
      return celsius;
    } else if (toUnit == "Fahrenheit") {
      return celsius * 9.0 / 5.0 + 32.0;
    } else if (toUnit == "Kelvin") {
      return celsius + 273.15;
    };
    
    return value; // Default fallback
  };

  // Main conversion function
  public query func convert(value: Float, category: Text, fromUnit: Text, toUnit: Text) : async Float {
    if (fromUnit == toUnit) {
      return value; // No conversion needed
    };
    
    // Special handling for temperature
    if (category == "Temperature") {
      return convertTemperature(value, fromUnit, toUnit);
    };
    
    // For other unit categories, use conversion factors
    let units = switch (category) {
      case "Length" { lengthUnits };
      case "Mass" { massUnits };
      case "Time" { timeUnits };
      case "Speed" { speedUnits };
      case "Area" { areaUnits };
      case "Volume" { volumeUnits };
      case "Energy" { energyUnits };
      case "Pressure" { pressureUnits };
      case _ { return value }; // Return original value if category not found
    };
    
    let fromUnitOpt = findUnit(units, fromUnit);
    let toUnitOpt = findUnit(units, toUnit);
    
    switch (fromUnitOpt, toUnitOpt) {
      case (?from, ?to) {
        // Convert to base unit, then to target unit
        let baseValue = value * from.toBase;
        return baseValue * to.fromBase;
      };
      case _ {
        return value; // Return original value if units not found
      };
    };
  };
  
  // Get unit details including abbreviations
  public query func getUnitDetails(category: Text) : async [{ name: Text; abbreviation: Text; }] {
    let units = switch (category) {
      case "Length" { lengthUnits };
      case "Mass" { massUnits };
      case "Temperature" { temperatureUnits };
      case "Time" { timeUnits };
      case "Speed" { speedUnits };
      case "Area" { areaUnits };
      case "Volume" { volumeUnits };
      case "Energy" { energyUnits };
      case "Pressure" { pressureUnits };
      case _ { [] }; 
    };
    
    return Array.map<Unit, { name: Text; abbreviation: Text; }>(
      units, 
      func(unit) { { name = unit.name; abbreviation = unit.abbreviation; } }
    );
  };

  // Validate if input value is a valid number
  public query func validateInput(valueText: Text) : async Bool {
    try {
      let _ = Float.fromText(valueText);
      return true;
    } catch (e) {
      return false;
    };
  };
}