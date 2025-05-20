import React, { useState, useEffect } from 'react';
import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory } from './declarations/unit_converter_backend/unit_converter_backend.did.js';
import './App.css';

function App() {
  const [categories, setCategories] = useState([]);
  const [units, setUnits] = useState([]);
  const [selectedCategory, setSelectedCategory] = useState('');
  const [fromUnit, setFromUnit] = useState('');
  const [toUnit, setToUnit] = useState('');
  const [value, setValue] = useState('');
  const [result, setResult] = useState('');
  const [canisterId, setCanisterId] = useState('[YOUR_CANISTER_ID]');
  const [actor, setActor] = useState(null);

  useEffect(() => {
    const agent = new HttpAgent({ host: 'https://icp0.io' });
    const actor = Actor.createActor(idlFactory, {
      agent,
      canisterId: canisterId,
    });
    setActor(actor);

    const fetchCategories = async () => {
      try {
        const categories = await actor.getUnitCategories();
        setCategories(categories);
        if (categories.length > 0) {
          setSelectedCategory(categories[0]);
        }
      } catch (error) {
        console.error('Error fetching categories:', error);
      }
    };

    fetchCategories();
  }, [canisterId]);

  useEffect(() => {
    const fetchUnits = async () => {
      if (selectedCategory && actor) {
        try {
          const units = await actor.getUnits(selectedCategory);
          setUnits(units);
          if (units.length > 0) {
            setFromUnit(units[0]);
            setToUnit(units.length > 1 ? units[1] : units[0]);
          }
        } catch (error) {
          console.error('Error fetching units:', error);
        }
      }
    };

    fetchUnits();
  }, [selectedCategory, actor]);

  const handleConvert = async () => {
    if (actor && value) {
      try {
        const numValue = parseFloat(value);
        const result = await actor.convert(numValue, selectedCategory, fromUnit, toUnit);
        setResult(result.toString());
      } catch (error) {
        console.error('Error converting:', error);
        setResult('Error: Could not convert value');
      }
    }
  };

  return (
    <div className="App">
      <h1>Unit Converter</h1>
      
      <div className="converter-container">
        <div className="input-group">
          <label>Category:</label>
          <select 
            value={selectedCategory} 
            onChange={(e) => setSelectedCategory(e.target.value)}
          >
            {categories.map((category) => (
              <option key={category} value={category}>{category}</option>
            ))}
          </select>
        </div>
        
        <div className="input-group">
          <label>Value:</label>
          <input 
            type="number" 
            value={value} 
            onChange={(e) => setValue(e.target.value)}
            placeholder="Enter value to convert"
          />
        </div>
        
        <div className="input-group">
          <label>From:</label>
          <select 
            value={fromUnit} 
            onChange={(e) => setFromUnit(e.target.value)}
          >
            {units.map((unit) => (
              <option key={unit} value={unit}>{unit}</option>
            ))}
          </select>
        </div>
        
        <div className="input-group">
          <label>To:</label>
          <select 
            value={toUnit} 
            onChange={(e) => setToUnit(e.target.value)}
          >
            {units.map((unit) => (
              <option key={unit} value={unit}>{unit}</option>
            ))}
          </select>
        </div>
        
        <button onClick={handleConvert}>Convert</button>
        
        {result && (
          <div className="result">
            <h3>Result:</h3>
            <p>{value} {fromUnit} = {result} {toUnit}</p>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;