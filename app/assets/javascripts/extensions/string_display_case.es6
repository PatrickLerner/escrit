String.prototype.displayCase = function(capitalize) {
  if (capitalize) {
    return `${this[0].charAt(0).toUpperCase()}${this.substr(1).toLowerCase()}`;
  } else {
    return this.toString();
  }
};

String.prototype.isCapitalized = function() {
  return this[0].toUpperCase() === this[0];
};
