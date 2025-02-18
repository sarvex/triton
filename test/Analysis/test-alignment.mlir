// RUN: triton-opt %s -test-print-alignment -split-input-file 2>&1 | FileCheck %s

// CHECK-LABEL: cast
func @cast() {
  // CHECK: Contiguity: [1] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [1]
  %cst = arith.constant 1 : i32
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [1]
  %0 = arith.extsi %cst : i32 to i64
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [128] ; ConstantValue: [1]
  %cst_tensor = arith.constant dense<1> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [128] ; ConstantValue: [1]
  %1 = tt.bitcast %cst_tensor : tensor<128xi32> -> tensor<128xi64>
  return
}

// -----

// CHECK-LABEL: add
func @add() {
  // CHECK: Contiguity: [128] ; Divisibility: [1073741824] ; Constancy: [1] ; ConstantValue: [None]
  %0 = tt.make_range {end = 128 : i32, start = 0 : i32} : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [128] ; ConstantValue: [1]
  %1 = arith.constant dense<1> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [128] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [None]
  %2 = arith.addi %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [128] ; ConstantValue: [127]
  %3 = arith.constant dense<127> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [128] ; Constancy: [128] ; ConstantValue: [128]
  %4 = arith.addi %1, %3 : tensor<128xi32>
  return
}

// -----

// CHECK-LABEL: sub
func @sub() {
  // CHECK: Contiguity: [128] ; Divisibility: [1073741824] ; Constancy: [1] ; ConstantValue: [None]
  %0 = tt.make_range {end = 128 : i32, start = 0 : i32} : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [128] ; ConstantValue: [1]
  %1 = arith.constant dense<1> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [128] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [None]
  %2 = arith.subi %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [128] ; ConstantValue: [129]
  %3 = arith.constant dense<129> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [128] ; Constancy: [128] ; ConstantValue: [128]
  %4 = arith.subi %3, %1 : tensor<128xi32>
  return
}

// -----

// CHECK-LABEL: mul
func @mul() {
  // CHECK: Contiguity: [128] ; Divisibility: [1073741824] ; Constancy: [1] ; ConstantValue: [None]
  %0 = tt.make_range {end = 128 : i32, start = 0 : i32} : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [128] ; ConstantValue: [1]
  %1 = arith.constant dense<1> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [128] ; Divisibility: [1073741824] ; Constancy: [1] ; ConstantValue: [None]
  %2 = arith.muli %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [128] ; Constancy: [128] ; ConstantValue: [128]
  %3 = arith.constant dense<128> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [128] ; Constancy: [128] ; ConstantValue: [128]
  %4 = arith.muli %3, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [2] ; Constancy: [128] ; ConstantValue: [2]
  %5 = arith.constant dense<2> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [256] ; Constancy: [128] ; ConstantValue: [256]
  %6 = arith.muli %4, %5 : tensor<128xi32>
  return
}

// -----

// CHECK-LABEL: div
func @div() {
  // CHECK: Contiguity: [128] ; Divisibility: [1073741824] ; Constancy: [1] ; ConstantValue: [None]
  %0 = tt.make_range {end = 128 : i32, start = 0 : i32} : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [128] ; ConstantValue: [1]
  %1 = arith.constant dense<1> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [128] ; Divisibility: [1073741824] ; Constancy: [1] ; ConstantValue: [None]
  %2 = arith.divsi %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [None]
  %3 = arith.divui %1, %0 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [64] ; Constancy: [128] ; ConstantValue: [64]
  %4 = arith.constant dense<64> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [16777216] ; Constancy: [64] ; ConstantValue: [None]
  %5 = arith.divsi %0, %4 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [None]
  %6 = arith.divsi %4, %0 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [64] ; Constancy: [128] ; ConstantValue: [64]
  %7 = arith.divsi %4, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [2] ; Constancy: [128] ; ConstantValue: [66]
  %8 = arith.constant dense<66> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [2] ; ConstantValue: [None]
  %9 = arith.divui %0, %8 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [128] ; Divisibility: [8192] ; Constancy: [1] ; ConstantValue: [None]
  %10 = tt.make_range {end = 8320 : i32, start = 8192 : i32} : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [128] ; Constancy: [64] ; ConstantValue: [None]
  %11 = arith.divsi %10, %4 : tensor<128xi32>
  return 
}

// -----

// CHECK-LABEL: rem
func @rem() {
  // CHECK: Contiguity: [128] ; Divisibility: [1073741824] ; Constancy: [1] ; ConstantValue: [None]
  %0 = tt.make_range {end = 128 : i32, start = 0 : i32} : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [128] ; ConstantValue: [1]
  %1 = arith.constant dense<1> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [4611686018427387904] ; Constancy: [128] ; ConstantValue: [0]
  %2 = arith.remsi %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [None]
  %3 = arith.remui %1, %0 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [64] ; Constancy: [128] ; ConstantValue: [64]
  %4 = arith.constant dense<64> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [64] ; Divisibility: [64] ; Constancy: [1] ; ConstantValue: [None]
  %5 = arith.remsi %0, %4 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [64] ; Constancy: [1] ; ConstantValue: [None]
  %6 = arith.remsi %4, %0 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [2] ; Constancy: [128] ; ConstantValue: [66]
  %7 = arith.constant dense<66> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [2] ; Divisibility: [2] ; Constancy: [1] ; ConstantValue: [None]
  %8 = arith.remui %0, %7 : tensor<128xi32>
  return 
}

// -----

// CHECK-LABEL: broadcast
func @broadcast() {
  // CHECK: Contiguity: [1] ; Divisibility: [64] ; Constancy: [128] ; ConstantValue: [64]
  %0 = arith.constant dense<64> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1, 1] ; Divisibility: [64, 1] ; Constancy: [128, 1] ; ConstantValue: [64]
  %1 = tt.expand_dims %0 {axis = 1 : i32} : (tensor<128xi32>) -> tensor<128x1xi32>
  // CHECK-NEXT: Contiguity: [1, 1] ; Divisibility: [64, 1] ; Constancy: [128, 128] ; ConstantValue: [64]
  %2 = tt.broadcast %1 : (tensor<128x1xi32>) -> tensor<128x128xi32>
  return
}

// -----

// CHECK-LABEL: splat
func @splat(%arg0: !tt.ptr<f32> {tt.divisibility = 16 : i32}) {
  // CHECK: Contiguity: [1, 1] ; Divisibility: [16, 16] ; Constancy: [128, 128] ; ConstantValue: [None]
  %0 = tt.splat %arg0 : (!tt.ptr<f32>) -> tensor<128x128x!tt.ptr<f32>>
  return
}

// -----

// CHECK-LABEL: cmp
func @cmp() {
  // CHECK: Contiguity: [128] ; Divisibility: [1073741824] ; Constancy: [1] ; ConstantValue: [None]
  %0 = tt.make_range {end = 128 : i32, start = 0 : i32} : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [4611686018427387904] ; Constancy: [128] ; ConstantValue: [0]
  %1 = arith.constant dense<0> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [128] ; ConstantValue: [None]
  %2 = arith.cmpi eq, %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [128] ; ConstantValue: [None]
  %3 = arith.cmpi slt, %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [None]
  %4 = arith.cmpi sle, %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [128] ; ConstantValue: [None]
  %5 = arith.cmpi sge, %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [8] ; Constancy: [128] ; ConstantValue: [8]
  %6 = arith.constant dense<8> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [8] ; ConstantValue: [None]
  %7 = arith.cmpi sgt, %0, %6 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [128] ; ConstantValue: [0]
  %8 = arith.cmpi sgt, %1, %6 : tensor<128xi32>
  return
}

// -----

// CHECK-LABEL: logic
func @logic() {
  // CHECK: Contiguity: [128] ; Divisibility: [1073741824] ; Constancy: [1] ; ConstantValue: [None]
  %0 = tt.make_range {end = 128 : i32, start = 0 : i32} : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [64] ; Constancy: [128] ; ConstantValue: [64]
  %1 = arith.constant dense<64> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [16777216] ; Constancy: [64] ; ConstantValue: [None]
  %2 = arith.divsi %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [8] ; Constancy: [128] ; ConstantValue: [8]
  %3 = arith.constant dense<8> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [134217728] ; Constancy: [8] ; ConstantValue: [None]
  %4 = arith.divsi %0, %3 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [None]
  %5 = arith.andi %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [None]
  %6 = arith.ori %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [None]
  %7 = arith.xori %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [8] ; ConstantValue: [None]
  %8 = arith.andi %2, %4 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [8] ; ConstantValue: [None]
  %9 = arith.ori %2, %4 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [8] ; ConstantValue: [None]
  %10 = arith.xori %2, %4 : tensor<128xi32>
  return
}

// -----

// CHECK-LABEL: select
func @select() {
  // CHECK: Contiguity: [128] ; Divisibility: [1073741824] ; Constancy: [1] ; ConstantValue: [None]
  %0 = tt.make_range {end = 128 : i32, start = 0 : i32} : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [4611686018427387904] ; Constancy: [128] ; ConstantValue: [0]
  %1 = arith.constant dense<0> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [128] ; ConstantValue: [None]
  %2 = arith.cmpi eq, %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [128] ; ConstantValue: [None]
  %3 = arith.cmpi slt, %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [4611686018427387904] ; Constancy: [1] ; ConstantValue: [0]
  %4 = arith.constant 0 : i1
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [4611686018427387904] ; Constancy: [128] ; ConstantValue: [0]
  %7 = tt.splat %4 : (i1) -> tensor<128xi1>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [4611686018427387904] ; Constancy: [128] ; ConstantValue: [0]
  %5 = select %4, %3, %7 : tensor<128xi1>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [128] ; ConstantValue: [None]
  %8 = "triton_gpu.select"(%7, %3, %2) : (tensor<128xi1>, tensor<128xi1>, tensor<128xi1>) -> tensor<128xi1>
  return
}

// -----

func @shift() {
  // CHECK: Contiguity: [128] ; Divisibility: [1073741824] ; Constancy: [1] ; ConstantValue: [None]
  %0 = tt.make_range {end = 128 : i32, start = 0 : i32} : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [8] ; Constancy: [128] ; ConstantValue: [8]
  %1 = arith.constant dense<8> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [4] ; Constancy: [128] ; ConstantValue: [4]
  %2 = arith.constant dense<4> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [274877906944] ; Constancy: [1] ; ConstantValue: [None]
  %3 = arith.shli %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [67108864] ; Constancy: [1] ; ConstantValue: [None]
  %4 = arith.shrsi %0, %2 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [128] ; Constancy: [128] ; ConstantValue: [128]
  %5 = arith.shli %1, %2 : tensor<128xi32>
  return
}

// -----

func @max_min() {
  // CHECK: Contiguity: [128] ; Divisibility: [1073741824] ; Constancy: [1] ; ConstantValue: [None]
  %0 = tt.make_range {end = 128 : i32, start = 0 : i32} : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [128] ; Divisibility: [64] ; Constancy: [1] ; ConstantValue: [None]
  %1 = tt.make_range {end = 192 : i32, start = 64 : i32} : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [None]
  %2 = arith.maxsi %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [None]
  %3 = arith.minsi %0, %1 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [8] ; Constancy: [128] ; ConstantValue: [8]
  %4 = arith.constant dense<8> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [4] ; Constancy: [128] ; ConstantValue: [4]
  %5 = arith.constant dense<4> : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [8]
  %6 = arith.maxsi %4, %5 : tensor<128xi32>
  return
}

// -----

// CHECK-LABEL: for
func @for() {
  // CHECK: Contiguity: [1, 1] ; Divisibility: [4611686018427387904, 4611686018427387904] ; Constancy: [128, 32] ; ConstantValue: [0]
  %a_init = arith.constant dense<0> : tensor<128x32xi32>
  // CHECK-NEXT: Contiguity: [1, 1] ; Divisibility: [1, 1] ; Constancy: [128, 32] ; ConstantValue: [1]
  %b_init = arith.constant dense<1> : tensor<128x32xi32>
  // CHECK-NEXT: Contiguity: [1, 1] ; Divisibility: [4, 4] ; Constancy: [128, 32] ; ConstantValue: [4]
  %c_init = arith.constant dense<4> : tensor<128x32xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [128] ; Constancy: [1] ; ConstantValue: [128]
  %ub = arith.constant 128 : index
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [4611686018427387904] ; Constancy: [1] ; ConstantValue: [0]
  %lb = arith.constant 0 : index
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [16] ; Constancy: [1] ; ConstantValue: [16]
  %step = arith.constant 16 : index
  %a, %b, %c = scf.for %iv = %lb to %ub step %step iter_args(%a = %a_init, %b = %b_init, %c = %c_init) -> (tensor<128x32xi32>, tensor<128x32xi32>, tensor<128x32xi32>) {
    // CHECK-NEXT: Contiguity: [1] ; Divisibility: [16] ; Constancy: [1] ; ConstantValue: [None]
    %t = arith.index_cast %iv : index to i32
    // CHECK: Contiguity: [1, 1] ; Divisibility: [1, 1] ; Constancy: [128, 32] ; ConstantValue: [None]
    // CHECK: Contiguity: [1, 1] ; Divisibility: [1, 1] ; Constancy: [128, 32] ; ConstantValue: [None]
    // CHECK: Contiguity: [1, 1] ; Divisibility: [4, 4] ; Constancy: [128, 32] ; ConstantValue: [4]
    scf.yield %b, %a, %c : tensor<128x32xi32>, tensor<128x32xi32>, tensor<128x32xi32>
  }
  return
}

// -----

// CHECK-LABEL: permute_2d
func @permute_2d(%arg0: !tt.ptr<f32> {tt.divisibility = 16 : i32}, %arg1: i32 {tt.divisibility = 16 : i32}, %arg2: !tt.ptr<f32> {tt.divisibility = 16 : i32}, %arg3: i32 {tt.divisibility = 16 : i32}) {
  // CHECK: Contiguity: [1, 1] ; Divisibility: [1, 1] ; Constancy: [128, 128] ; ConstantValue: [1]
  %cst = arith.constant dense<true> : tensor<128x128xi1>
  // CHECK-NEXT: Contiguity: [1, 1] ; Divisibility: [1, 1] ; Constancy: [1, 1] ; ConstantValue: [None]
  %cst_0 = arith.constant dense<0.000000e+00> : tensor<128x128xf32>
  // CHECK-NEXT: Contiguity: [128] ; Divisibility: [1073741824] ; Constancy: [1] ; ConstantValue: [None]
  %0 = tt.make_range {end = 128 : i32, start = 0 : i32} : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [128] ; Divisibility: [1073741824] ; Constancy: [1] ; ConstantValue: [None]
  %1 = tt.make_range {end = 128 : i32, start = 0 : i32} : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [128, 1] ; Divisibility: [1073741824, 1] ; Constancy: [1, 1] ; ConstantValue: [None]
  %2 = tt.expand_dims %0 {axis = 1 : i32} : (tensor<128xi32>) -> tensor<128x1xi32>
  // CHECK-NEXT: Contiguity: [1, 1] ; Divisibility: [16, 16] ; Constancy: [128, 1] ; ConstantValue: [None]
  %3 = tt.splat %arg1 : (i32) -> tensor<128x1xi32>
  // CHECK-NEXT: Contiguity: [1, 1] ; Divisibility: [17179869184, 16] ; Constancy: [1, 1] ; ConstantValue: [None]
  %4 = arith.muli %2, %3 : tensor<128x1xi32>
  // CHECK-NEXT: Contiguity: [1, 1] ; Divisibility: [16, 16] ; Constancy: [128, 1] ; ConstantValue: [None]
  %5 = tt.splat %arg0 : (!tt.ptr<f32>) -> tensor<128x1x!tt.ptr<f32>>
  // CHECK-NEXT: Contiguity: [1, 1] ; Divisibility: [16, 16] ; Constancy: [1, 1] ; ConstantValue: [None]
  %6 = tt.addptr %5, %4 : tensor<128x1x!tt.ptr<f32>>, tensor<128x1xi32>
  // CHECK-NEXT: Contiguity: [1, 128] ; Divisibility: [1, 1073741824] ; Constancy: [1, 1] ; ConstantValue: [None]
  %7 = tt.expand_dims %1 {axis = 0 : i32}: (tensor<128xi32>) -> tensor<1x128xi32>
  // CHECK-NEXT: Contiguity: [1, 1] ; Divisibility: [16, 16] ; Constancy: [1, 128] ; ConstantValue: [None]
  %8 = tt.broadcast %6 : (tensor<128x1x!tt.ptr<f32>>) -> tensor<128x128x!tt.ptr<f32>>
  // CHECK-NEXT: Contiguity: [1, 128] ; Divisibility: [1, 1073741824] ; Constancy: [128, 1] ; ConstantValue: [None]
  %9 = tt.broadcast %7 : (tensor<1x128xi32>) -> tensor<128x128xi32>
  // CHECK-NEXT: Contiguity: [1, 128] ; Divisibility: [1, 16] ; Constancy: [1, 1] ; ConstantValue: [None]
  %10 = tt.addptr %8, %9 : tensor<128x128x!tt.ptr<f32>>, tensor<128x128xi32>
  // CHECK-NEXT: Contiguity: [128, 1] ; Divisibility: [1073741824, 1] ; Constancy: [1, 1] ; ConstantValue: [None]
  %11 = tt.expand_dims %0 {axis = 1 : i32}: (tensor<128xi32>) -> tensor<128x1xi32>
  // CHECK-NEXT: Contiguity: [1, 1] ; Divisibility: [16, 16] ; Constancy: [128, 1] ; ConstantValue: [None]
  %12 = tt.splat %arg2 : (!tt.ptr<f32>) -> tensor<128x1x!tt.ptr<f32>>
  // CHECK-NEXT: Contiguity: [128, 1] ; Divisibility: [16, 1] ; Constancy: [1, 1] ; ConstantValue: [None]
  %13 = tt.addptr %12, %11 : tensor<128x1x!tt.ptr<f32>>, tensor<128x1xi32>
  // CHECK-NEXT: Contiguity: [1, 128] ; Divisibility: [1, 1073741824] ; Constancy: [1, 1] ; ConstantValue: [None]
  %14 = tt.expand_dims %1 {axis = 0 : i32} : (tensor<128xi32>) -> tensor<1x128xi32>
  // CHECK-NEXT: Contiguity: [1, 1] ; Divisibility: [16, 16] ; Constancy: [1, 128] ; ConstantValue: [None]
  %15 = tt.splat %arg3 : (i32) -> tensor<1x128xi32>
  // CHECK-NEXT: Contiguity: [1, 1] ; Divisibility: [16, 17179869184] ; Constancy: [1, 1] ; ConstantValue: [None]
  %16 = arith.muli %14, %15 : tensor<1x128xi32>
  // CHECK-NEXT: Contiguity: [128, 1] ; Divisibility: [16, 1] ; Constancy: [1, 128] ; ConstantValue: [None]
  %17 = tt.broadcast %13 : (tensor<128x1x!tt.ptr<f32>>) -> tensor<128x128x!tt.ptr<f32>>
  // CHECK-NEXT: Contiguity: [1, 1] ; Divisibility: [16, 17179869184] ; Constancy: [128, 1] ; ConstantValue: [None]
  %18 = tt.broadcast %16 : (tensor<1x128xi32>) -> tensor<128x128xi32>
  // CHECK-NEXT: Contiguity: [128, 1] ; Divisibility: [16, 1] ; Constancy: [1, 1] ; ConstantValue: [None]
  %19 = tt.addptr %17, %18 : tensor<128x128x!tt.ptr<f32>>, tensor<128x128xi32>
  // CHECK-NEXT: Contiguity: [1, 1] ; Divisibility: [1, 1] ; Constancy: [1, 1] ; ConstantValue: [None]
  %20 = tt.load %10, %cst, %cst_0 {cache = 1 : i32, evict = 1 : i32, isVolatile = false} : tensor<128x128xf32>
  tt.store %19, %20, %cst : tensor<128x128xf32>
  return
}

// -----

module {

// This is a tiny test for verifying StoreOp-related alignment, It simply store a constant to a buffer.
// CHECK-LABEL: store_constant_align
func @store_constant_align(%addr: !tt.ptr<f32> {tt.divisibility = 16 : i32}, %n: i32 {tt.divisibility = 16 : i32}) {
  // CHECK: Contiguity: [1] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [None]
  %pid = tt.get_program_id {axis = 0 : i32} : i32
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [128] ; Constancy: [1] ; ConstantValue: [128]
  %c128_i32 = arith.constant 128 : i32
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [128] ; Constancy: [1] ; ConstantValue: [None]
  %1 = arith.muli %pid, %c128_i32 : i32
  // CHECK-NEXT: Contiguity: [128] ; Divisibility: [1073741824] ; Constancy: [1] ; ConstantValue: [None]
  %2 = tt.make_range {end = 128 : i32, start = 0 : i32} : tensor<128xi32>
 // CHECK-NEXT: Contiguity: [1] ; Divisibility: [128] ; Constancy: [128] ; ConstantValue: [None]
  %3 = tt.splat %1 : (i32) -> tensor<128xi32>
 // CHECK-NEXT: Contiguity: [128] ; Divisibility: [128] ; Constancy: [1] ; ConstantValue: [None]
  %4 = arith.addi %3, %2 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [16] ; Constancy: [128] ; ConstantValue: [None]
  %5 = tt.splat %addr : (!tt.ptr<f32>) -> tensor<128x!tt.ptr<f32>>
  // CHECK-NEXT: Contiguity: [128] ; Divisibility: [16] ; Constancy: [1] ; ConstantValue: [None]
  %6 = tt.addptr %5, %4 : tensor<128x!tt.ptr<f32>>, tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [16] ; Constancy: [128] ; ConstantValue: [None]
  %9 = tt.splat %n : (i32) -> tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [16] ; ConstantValue: [None]
  %mask = arith.cmpi slt, %4, %9 : tensor<128xi32>
  // CHECK-NEXT: Contiguity: [1] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [None]
  %cst = arith.constant dense<0.0> : tensor<128xf32>
  tt.store %5, %cst, %mask : tensor<128xf32>
  return
}

}

// -----

// This IR is dumped from vecadd test.
// Note, the hint {tt.divisibility = 16 : i32} for %n_elements affects the alignment of mask.
// CHECK-LABEL: vecadd_mask_align_16
func @vecadd_mask_align_16(%arg0: !tt.ptr<f32> {tt.divisibility = 16 : i32}, %arg1: !tt.ptr<f32> {tt.divisibility = 16 : i32}, %arg2: !tt.ptr<f32> {tt.divisibility = 16 : i32}, %n_elements: i32 {tt.divisibility = 16 : i32}) {
  %c64_i32 = arith.constant 64 : i32
  %0 = tt.get_program_id {axis = 0 : i32} : i32
  %1 = arith.muli %0, %c64_i32 : i32
  %2 = tt.make_range {end = 64 : i32, start = 0 : i32} : tensor<64xi32>
  %3 = tt.splat %1 : (i32) -> tensor<64xi32>
  %4 = arith.addi %3, %2 : tensor<64xi32>
  %5 = tt.splat %arg0 : (!tt.ptr<f32>) -> tensor<64x!tt.ptr<f32>>
  %6 = tt.addptr %5, %4 : tensor<64x!tt.ptr<f32>>, tensor<64xi32>
  %7 = tt.splat %arg1 : (!tt.ptr<f32>) -> tensor<64x!tt.ptr<f32>>
  %8 = tt.addptr %7, %4 : tensor<64x!tt.ptr<f32>>, tensor<64xi32>
  %9 = tt.splat %n_elements : (i32) -> tensor<64xi32>
  // CHECK: Contiguity: [1] ; Divisibility: [1] ; Constancy: [16] ; ConstantValue: [None] ( %{{.*}} = arith.cmpi slt, %{{.*}}, %{{.*}} : tensor<64xi32> )
  %mask = arith.cmpi slt, %4, %9 : tensor<64xi32>
  %11 = tt.load %6, %mask {cache = 1 : i32, evict = 1 : i32, isVolatile = false} : tensor<64xf32>
  %12 = tt.load %8, %mask {cache = 1 : i32, evict = 1 : i32, isVolatile = false} : tensor<64xf32>
  %13 = arith.addf %11, %12 : tensor<64xf32>
  %14 = tt.splat %arg2 : (!tt.ptr<f32>) -> tensor<64x!tt.ptr<f32>>
  // CHECK: Contiguity: [64] ; Divisibility: [16] ; Constancy: [1] ; ConstantValue: [None] ( %{{.*}} = tt.addptr %{{.*}}, %{{.*}} : tensor<64x!tt.ptr<f32>>, tensor<64xi32> )
  %15 = tt.addptr %14, %4 : tensor<64x!tt.ptr<f32>>, tensor<64xi32>
  tt.store %15, %13, %mask : tensor<64xf32>
  return
}

// -----

// This IR is dumped from vecadd test.
// Note, there is no divisibility hint for %n_elements, Triton should assume its divisibility to be 1 by default.
// CHECK-LABEL: vecadd_mask_align_1
func @vecadd_mask_align_1(%arg0: !tt.ptr<f32> {tt.divisibility = 16 : i32}, %arg1: !tt.ptr<f32> {tt.divisibility = 16 : i32}, %arg2: !tt.ptr<f32> {tt.divisibility = 16 : i32}, %n_elements: i32) {
  %c64_i32 = arith.constant 64 : i32
  %0 = tt.get_program_id {axis = 0 : i32} : i32
  %1 = arith.muli %0, %c64_i32 : i32
  %2 = tt.make_range {end = 64 : i32, start = 0 : i32} : tensor<64xi32>
  %3 = tt.splat %1 : (i32) -> tensor<64xi32>
  %4 = arith.addi %3, %2 : tensor<64xi32>
  %5 = tt.splat %arg0 : (!tt.ptr<f32>) -> tensor<64x!tt.ptr<f32>>
  %6 = tt.addptr %5, %4 : tensor<64x!tt.ptr<f32>>, tensor<64xi32>
  %7 = tt.splat %arg1 : (!tt.ptr<f32>) -> tensor<64x!tt.ptr<f32>>
  %8 = tt.addptr %7, %4 : tensor<64x!tt.ptr<f32>>, tensor<64xi32>
  %9 = tt.splat %n_elements : (i32) -> tensor<64xi32>
  // CHECK: Contiguity: [1] ; Divisibility: [1] ; Constancy: [1] ; ConstantValue: [None] ( %{{.*}} = arith.cmpi slt, %{{.*}}, %{{.*}} : tensor<64xi32> )
  %10 = arith.cmpi slt, %4, %9 : tensor<64xi32>
  %11 = tt.load %6, %10 {cache = 1 : i32, evict = 1 : i32, isVolatile = false} : tensor<64xf32>
  %12 = tt.load %8, %10 {cache = 1 : i32, evict = 1 : i32, isVolatile = false} : tensor<64xf32>
  %13 = arith.addf %11, %12 : tensor<64xf32>
  %14 = tt.splat %arg2 : (!tt.ptr<f32>) -> tensor<64x!tt.ptr<f32>>
  %15 = tt.addptr %14, %4 : tensor<64x!tt.ptr<f32>>, tensor<64xi32>
  tt.store %15, %13, %10 : tensor<64xf32>
  return
}
