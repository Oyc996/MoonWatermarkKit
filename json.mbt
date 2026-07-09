///|
fn escape_json(value : String) -> String {
  let buf = StringBuilder()
  for i = 0; i < value.length(); i = i + 1 {
    match value.get_char(i) {
      Some('\\') => buf.write_string("\\\\")
      Some('"') => buf.write_string("\\\"")
      Some('\n') => buf.write_string("\\n")
      Some('\r') => buf.write_string("\\r")
      Some('\t') => buf.write_string("\\t")
      Some(ch) => buf.write_char(ch)
      None => ()
    }
  }
  buf.to_string()
}

///|
pub fn TimeWindow::to_json(self : TimeWindow) -> String {
  "{\"start_ms\":\{self.start_ms},\"end_ms\":\{self.end_ms}}"
}

///|
pub fn EventAssignment::to_json(self : EventAssignment) -> String {
  "{\"key\":\"\{escape_json(self.event.key)}\",\"status\":\"\{self.status.name()}\",\"watermark_ms\":\{self.watermark_ms},\"windows\":\{self.windows.length()}}"
}

///|
pub fn StreamAudit::to_json(self : StreamAudit) -> String {
  "{\"total\":\{self.total},\"on_time\":\{self.on_time},\"late\":\{self.late},\"too_late\":\{self.too_late},\"accepted\":\{self.accepted}}"
}

///|
pub fn WindowAggregate::to_json(self : WindowAggregate) -> String {
  "{\"key\":\"\{escape_json(self.key)}\",\"window\":\{self.window.to_json()},\"count\":\{self.count},\"sum\":\{self.sum},\"late\":\{self.late},\"dropped\":\{self.dropped}}"
}
