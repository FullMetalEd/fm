with import <nixpkgs> {};

python3Packages.buildPythonPackage {
  pname = "pydrexcel";
  version = "0.1.0";

  src = ./.;
  
  propagatedBuildInputs = with python3Packages; [
    pyinstaller
    pyyaml
  ];

  checkInputs = with python3Packages; [
    pytest
    mock
  ];

  doCheck = false;
  checkPhase = ''
    pytest
  '';
  pythonImportsCheck = [ "pandas" ];
}
 
