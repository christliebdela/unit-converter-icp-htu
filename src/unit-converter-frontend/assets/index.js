// Import the canister ID and actor declarations
import { unit_converter_backend } from "../../declarations/unit-converter-backend";

document.addEventListener('DOMContentLoaded', async () => {
  // DOM elements
  const categorySelect = document.getElementById('categorySelect');
  const fromUnitSelect = document.getElementById('fromUnitSelect');
  const toUnitSelect = document.getElementById('toUnitSelect');
  const inputValue = document.getElementById('inputValue');
  const resultValue = document.getElementById('resultValue');
  const convertBtn = document.getElementById('convertBtn');
  const swapBtn = document.getElementById('swapBtn');

  // Load categories when the page loads
  try {
    const categories = await unit_converter_backend.getUnitCategories();
    populateSelect(categorySelect, categories);
    
    // Load units for the first category
    if (categories.length > 0) {
      await loadUnitsForCategory(categories[0]);
    }
  } catch (error) {
    console.error("Error loading categories:", error);
    showError("Failed to load unit categories. Please try again later.");
  }

  // Event listeners
  categorySelect.addEventListener('change', async () => {
    await loadUnitsForCategory(categorySelect.value);
  });

  convertBtn.addEventListener('click', performConversion);
  
  inputValue.addEventListener('input', () => {
    validateInput(inputValue.value);
  });

  swapBtn.addEventListener('click', () => {
    const fromUnit = fromUnitSelect.value;
    const toUnit = toUnitSelect.value;
    
    // Find the index of the selected options
    const fromIndex = [...fromUnitSelect.options].findIndex(opt => opt.value === fromUnit);
    const toIndex = [...toUnitSelect.options].findIndex(opt => opt.value === toUnit);
    
    // Set the new selected options
    fromUnitSelect.selectedIndex = toIndex;
    toUnitSelect.selectedIndex = fromIndex;
    
    // Perform the conversion with the swapped units
    performConversion();
  });

  // Helper functions
  async function loadUnitsForCategory(category) {
    try {
      // Get unit details (names and abbreviations)
      const unitDetails = await unit_converter_backend.getUnitDetails(category);
      
      // Clear existing options
      fromUnitSelect.innerHTML = '';
      toUnitSelect.innerHTML = '';
      
      // Add new options with abbreviations
      unitDetails.forEach((unit) => {
        const fromOption = document.createElement('option');
        fromOption.value = unit.name;
        fromOption.textContent = `${unit.name} (${unit.abbreviation})`;
        fromUnitSelect.appendChild(fromOption);
        
        const toOption = document.createElement('option');
        toOption.value = unit.name;
        toOption.textContent = `${unit.name} (${unit.abbreviation})`;
        toUnitSelect.appendChild(toOption);
      });
      
      // Set default selections (different if possible)
      if (unitDetails.length > 1) {
        toUnitSelect.selectedIndex = 1;
      }
      
      // Clear result
      resultValue.textContent = '0';
    } catch (error) {
      console.error(`Error loading units for ${category}:`, error);
      showError(`Failed to load units for ${category}. Please try again.`);
    }
  }

  async function performConversion() {
    const value = parseFloat(inputValue.value);
    
    if (isNaN(value)) {
      resultValue.textContent = 'Invalid input';
      return;
    }
    
    try {
      const isValid = await unit_converter_backend.validateInput(inputValue.value);
      
      if (!isValid) {
        resultValue.textContent = 'Invalid input';
        return;
      }
      
      const result = await unit_converter_backend.convert(
        value,
        categorySelect.value,
        fromUnitSelect.value,
        toUnitSelect.value
      );
      
      // Format the result based on decimal places
      const formattedResult = formatNumber(result);
      resultValue.textContent = formattedResult;
    } catch (error) {
      console.error("Conversion error:", error);
      resultValue.textContent = 'Error';
    }
  }

  function validateInput(value) {
    // Simple client-side validation for immediate feedback
    const regex = /^-?\d*\.?\d*$/;
    const isValid = regex.test(value);
    
    if (!isValid && value !== '') {
      inputValue.classList.add('error');
    } else {
      inputValue.classList.remove('error');
    }
  }

  function populateSelect(selectElement, options) {
    selectElement.innerHTML = '';
    options.forEach(option => {
      const optionElement = document.createElement('option');
      optionElement.value = option;
      optionElement.textContent = option;
      selectElement.appendChild(optionElement);
    });
  }

  function formatNumber(num) {
    // If the number is an integer, show it as an integer
    if (Number.isInteger(num)) {
      return num.toString();
    }
    
    // Handle scientific notation for very large or small numbers
    if (Math.abs(num) < 0.0001 || Math.abs(num) > 9999999) {
      return num.toExponential(6);
    }
    
    // Otherwise show up to 6 decimal places, removing trailing zeros
    return parseFloat(num.toFixed(6)).toString();
  }

  function showError(message) {
    // A simple error display function
    const errorDiv = document.createElement('div');
    errorDiv.className = 'error-message';
    errorDiv.textContent = message;
    
    document.querySelector('.card').prepend(errorDiv);
    
    // Remove the error after 5 seconds
    setTimeout(() => {
      errorDiv.remove();
    }, 5000);
  }
});