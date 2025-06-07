// lib/core/utils/validators.dart
import '../constants/app_strings.dart';

class Validators {
  Validators._();

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.invalidEmail;
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe contener al menos una mayúscula';
    }
    
    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'La contraseña debe contener al menos una minúscula';
    }
    
    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe contener al menos un número';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value != password) {
      return AppStrings.passwordMismatch;
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    // Check if contains only letters and spaces
    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'El nombre solo puede contener letras';
    }
    
    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length < 8) {
      return 'Número de teléfono muy corto';
    }
    
    if (digitsOnly.length > 15) {
      return 'Número de teléfono muy largo';
    }
    
    return null;
  }

  // Optional phone validation (can be empty)
  static String? validateOptionalPhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    return validatePhone(value);
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value.length < 10) {
      return 'La dirección debe ser más específica';
    }
    
    return null;
  }

  // Optional address validation
  static String? validateOptionalAddress(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    return validateAddress(value);
  }

  // Generic required field validation
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return fieldName != null 
          ? '$fieldName es requerido'
          : AppStrings.fieldRequired;
    }
    
    return null;
  }

  // Quantity validation
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    final quantity = int.tryParse(value);
    
    if (quantity == null) {
      return 'Ingresa un número válido';
    }
    
    if (quantity <= 0) {
      return 'La cantidad debe ser mayor a 0';
    }
    
    if (quantity > 99) {
      return 'Cantidad máxima: 99';
    }
    
    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    final price = double.tryParse(value);
    
    if (price == null) {
      return 'Ingresa un precio válido';
    }
    
    if (price <= 0) {
      return 'El precio debe ser mayor a 0';
    }
    
    return null;
  }

  // Card number validation
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    // Remove spaces and dashes
    final cardNumber = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check if contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cardNumber)) {
      return 'Número de tarjeta inválido';
    }
    
    // Check length (most cards are 13-19 digits)
    if (cardNumber.length < 13 || cardNumber.length > 19) {
      return 'Número de tarjeta inválido';
    }
    
    // Luhn algorithm validation
    if (!_luhnValidation(cardNumber)) {
      return 'Número de tarjeta inválido';
    }
    
    return null;
  }

  // CVV validation
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    // Remove all non-digit characters
    final cvv = value.replaceAll(RegExp(r'\D'), '');
    
    // CVV should be 3 or 4 digits
    if (cvv.length < 3 || cvv.length > 4) {
      return 'CVV inválido';
    }
    
    return null;
  }

  // Expiry date validation (MM/YY format)
  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    // Check format MM/YY
    final expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})');
    if (!expiryRegex.hasMatch(value)) {
      return 'Formato inválido (MM/AA)';
    }
    
    final parts = value.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]) + 2000; // Convert YY to YYYY
    
    final now = DateTime.now();
    final expiryDate = DateTime(year, month);
    final currentMonth = DateTime(now.year, now.month);
    
    if (expiryDate.isBefore(currentMonth)) {
      return 'Tarjeta expirada';
    }
    
    return null;
  }

  // Card holder name validation
  static String? validateCardHolderName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value.length < 2) {
      return 'Nombre muy corto';
    }
    
    // Check if contains only letters, spaces, and common punctuation
    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s\.\-\]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Nombre inválido';
    }
    
    return null;
  }

  // Search query validation
  static String? validateSearchQuery(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa algo para buscar';
    }
    
    if (value.length < 2) {
      return 'Búsqueda muy corta';
    }
    
    return null;
  }

  // Review text validation
  static String? validateReviewText(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value.length < 10) {
      return 'La reseña debe tener al menos 10 caracteres';
    }
    
    if (value.length > 500) {
      return 'La reseña no puede exceder 500 caracteres';
    }
    
    return null;
  }

  // Rating validation
  static String? validateRating(double? value) {
    if (value == null) {
      return 'Selecciona una calificación';
    }
    
    if (value < 1 || value > 5) {
      return 'Calificación inválida';
    }
    
    return null;
  }

  // Age validation (for birth date)
  static String? validateAge(DateTime? birthDate) {
    if (birthDate == null) {
      return AppStrings.fieldRequired;
    }
    
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    
    // Check if birthday hasn't occurred this year
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      // Subtract one year if birthday hasn't occurred
      final adjustedAge = age - 1;
      if (adjustedAge < 13) {
        return 'Debes tener al menos 13 años';
      }
    } else {
      if (age < 13) {
        return 'Debes tener al menos 13 años';
      }
    }
    
    if (age > 120) {
      return 'Fecha de nacimiento inválida';
    }
    
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'URL inválida';
    }
    
    return null;
  }

  // Optional URL validation
  static String? validateOptionalUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    return validateUrl(value);
  }

  // Discount percentage validation
  static String? validateDiscountPercentage(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    final discount = double.tryParse(value);
    
    if (discount == null) {
      return 'Ingresa un porcentaje válido';
    }
    
    if (discount < 0 || discount > 100) {
      return 'El descuento debe estar entre 0% y 100%';
    }
    
    return null;
  }

  // Helper method for Luhn algorithm (credit card validation)
  static bool _luhnValidation(String cardNumber) {
    int sum = 0;
    bool alternate = false;
    
    // Process digits from right to left
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return (sum % 10) == 0;
  }

  // Combine multiple validators
  static String? combineValidators(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  // Password strength checker (returns strength level 0-4)
  static int getPasswordStrength(String password) {
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    return strength;
  }

  // Get password strength text
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Muy débil';
      case 2:
        return 'Débil';
      case 3:
        return 'Moderada';
      case 4:
        return 'Fuerte';
      case 5:
        return 'Muy fuerte';
      default:
        return 'Muy débil';
    }
  }

  // Get password strength color
  static String getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'error';
      case 2:
        return 'warning';
      case 3:
        return 'info';
      case 4:
      case 5:
        return 'success';
      default:
        return 'error';
    }
  }
}