import simplifile

pub fn read(filename: String) -> String {
  case simplifile.read(filename) {
    Ok(content) -> content
    Error(_) -> ""
  }
}
