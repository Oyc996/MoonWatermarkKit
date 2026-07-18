/// A named source or partition tracked by a coordinator.

///|
pub(all) struct PartitionWatermark {
  partition : String
  state : WatermarkState
  idle : Bool
} derive(Eq, Debug)

/// Coordinates independent source watermarks into one conservative global
/// watermark. Idle partitions are excluded so a stalled source cannot block
/// an otherwise healthy stream indefinitely.

///|
pub(all) struct WatermarkCoordinator {
  policy : WatermarkPolicy
  partitions : Array[PartitionWatermark]
} derive(Eq, Debug)

///|
pub fn WatermarkCoordinator::new(
  policy : WatermarkPolicy,
) -> WatermarkCoordinator {
  { policy, partitions: [] }
}

/// Records an event for one named source. The operation is immutable so it is
/// straightforward for callers to checkpoint the returned coordinator state.

///|
pub fn WatermarkCoordinator::observe(
  self : WatermarkCoordinator,
  partition : String,
  event : StreamEvent,
) -> WatermarkCoordinator {
  let partitions = []
  let mut found = false
  let mut index = 0
  while index < self.partitions.length() {
    let current = self.partitions[index]
    if current.partition == partition {
      partitions.push({
        partition,
        state: current.state.observe(event),
        idle: false,
      })
      found = true
    } else {
      partitions.push(current)
    }
    index = index + 1
  }
  if !found {
    partitions.push({
      partition,
      state: WatermarkState::new(self.policy).observe(event),
      idle: false,
    })
  }
  { policy: self.policy, partitions }
}

/// Refreshes idleness using the caller's clock. It never advances any source
/// watermark; it only controls whether a source participates in the minimum.

///|
pub fn WatermarkCoordinator::refresh_idle(
  self : WatermarkCoordinator,
  now_ms : Int,
) -> WatermarkCoordinator {
  let partitions = []
  let mut index = 0
  while index < self.partitions.length() {
    let current = self.partitions[index]
    partitions.push({
      partition: current.partition,
      state: current.state,
      idle: current.state.mark_idle(now_ms),
    })
    index = index + 1
  }
  { policy: self.policy, partitions }
}

/// Returns the minimum watermark among initialized, non-idle partitions.
/// `None` means no active source is currently eligible to advance windows.

///|
pub fn WatermarkCoordinator::global_watermark(
  self : WatermarkCoordinator,
) -> Int? {
  let mut found = false
  let mut watermark = 0
  let mut index = 0
  while index < self.partitions.length() {
    let current = self.partitions[index]
    if !current.idle && current.state.initialized {
      if !found || current.state.current_watermark_ms < watermark {
        watermark = current.state.current_watermark_ms
      }
      found = true
    }
    index = index + 1
  }
  if found {
    Some(watermark)
  } else {
    None
  }
}

///|
pub fn WatermarkCoordinator::active_partition_count(
  self : WatermarkCoordinator,
) -> Int {
  let mut count = 0
  let mut index = 0
  while index < self.partitions.length() {
    let current = self.partitions[index]
    if !current.idle && current.state.initialized {
      count = count + 1
    }
    index = index + 1
  }
  count
}
