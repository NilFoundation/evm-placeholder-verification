const asTable = require('as-table');
const fs = require("fs");

file = 'time_execution.log';
let time_execution = fs.readFileSync(file).toString().trim();
time_execution = time_execution.split("\n");

file = 'preprocessor.log';
let preprocessor = fs.readFileSync(file).toString().trim();
preprocessor = preprocessor.split("\n");

file = 'private.log';
let private = fs.readFileSync(file).toString().trim();
private = private.split("\n");

file = 'permutation.log';
let permutation = fs.readFileSync(file).toString().trim();
permutation = permutation.split("\n");

file = 'gate.log';
let gate = fs.readFileSync(file).toString().trim();
gate = gate.split("\n");

file = 'quotient.log';
let quotient = fs.readFileSync(file).toString().trim();
quotient = quotient.split("\n");

file = 'polynomial.log';
let polynomial = fs.readFileSync(file).toString().trim();
polynomial = polynomial.split("\n");

// blueprint_hashes_plonk_sha256_process_test blueprint_hashes_plonk_sha512_process_test blueprint_non_native_plonk_non_native_demo_test
// blueprint_non_native_plonk_non_native_range_test blueprint_non_native_plonk_fixed_base_mul_test blueprint_non_native_plonk_complete_addition_test
// blueprint_non_native_plonk_var_base_mul_per_bit_test

// const tests = {
//     'blueprint_hashes_plonk_sha256_process_test': {time_execution: time_execution[1], preprocessor: preprocessor[1], private: private[1], permutation: permutation[1], gate: gate[1], quotient: quotient[1], polynomial: polynomial[1]},
//     'blueprint_hashes_plonk_sha512_process_test': {time_execution: time_execution[2], preprocessor: preprocessor[2], private: private[2], permutation: permutation[2], gate: gate[2], quotient: quotient[2], polynomial: polynomial[2]},
//     'blueprint_non_native_plonk_non_native_demo_test': {time_execution: time_execution[4], preprocessor: preprocessor[4], private: private[4], permutation: permutation[4], gate: gate[4], quotient: quotient[4], polynomial: polynomial[3]},
//     'blueprint_non_native_plonk_non_native_range_test': {time_execution: time_execution[7], preprocessor: preprocessor[7], private: private[7], permutation: permutation[7], gate: gate[7], quotient: quotient[7], polynomial: polynomial[7]},
//     'blueprint_non_native_plonk_fixed_base_mul_test': {time_execution: time_execution[8], preprocessor: preprocessor[8], private: private[8], permutation: permutation[8], gate: gate[8], quotient: quotient[8], polynomial: polynomial[8]},
//     'blueprint_non_native_plonk_complete_addition_test': {time_execution: time_execution[9], preprocessor: preprocessor[9], private: private[9], permutation: permutation[9], gate: gate[9], quotient: quotient[9], polynomial: polynomial[9]}
//     'blueprint_non_native_plonk_var_base_mul_per_bit_test': {time_execution: time_execution[9], preprocessor: preprocessor[9], private: private[9], permutation: permutation[9], gate: gate[9], quotient: quotient[9], polynomial: polynomial[9]}
// };

// const tests_name = ["blueprint_hashes_plonk_sha256_process_test", "blueprint_hashes_plonk_sha512_process_test", "blueprint_non_native_plonk_non_native_demo_test",
// "blueprint_non_native_plonk_non_native_range_test", "blueprint_non_native_plonk_fixed_base_mul_test", "blueprint_non_native_plonk_complete_addition_test",
// "blueprint_non_native_plonk_var_base_mul_per_bit_test", "blueprint_non_native_plonk_variable_base_multiplication_test"]

const tests_name = ["actor_blueprint_hashes_plonk_sha256_process_test", "actor_blueprint_hashes_plonk_sha512_process_test", "actor_blueprint_non_native_plonk_non_native_demo_test",
"actor_blueprint_non_native_plonk_non_native_range_test", "actor_blueprint_non_native_plonk_fixed_base_mul_test", "actor_blueprint_non_native_plonk_complete_addition_test",
"actor_blueprint_non_native_plonk_var_base_mul_per_bit_test", "actor_blueprint_non_native_plonk_variable_base_multiplication_test"]

let tests = {};
for (let i = 0; i < tests_name.length; i++) {
    tests[tests_name[i]] = {time_execution: time_execution[i], preprocessor: preprocessor[i], private: private[i], permutation: permutation[i], gate: gate[i], quotient: quotient[i], polynomial: polynomial[i]};
}

const delimiter = ' | ';
const tab = '    ';
const emptyLine = '';
const noData = '-'

const asTableConfig = {
    title: x => {
        let title = x;

        if (x === 'SolanaProof') {
            title = 'Solana proof';
        }
        
        return title;
    },
    delimiter: delimiter
};

// const tableRows = [
//     { Name: 'Solana component for $M$ validators', Test: null },
//     { Name: emptyLine },
//     { Name: 'for $i$ from $n_1 + 1$ to $n_2 + 32$' },
//     { Name: `${tab}H_{B_i} = sha256_component`, Test: tests.blueprint_hashes_plonk_sha256_process_test, SolanaProof: 'Bank hash' },
//     { Name: emptyLine },
//     { Name: 'for $j$ from $0$ to $M$:' },
//     { Name: `${tab}Ed25519_component for $H_{B_{n_2 + 32}}$`, Test: tests.blueprint_non_native_plonk_non_native_demo_test, SolanaProof: 'Signatures' },
//     // { Name: `${tab}Ed25519_component for $H_{B_{n_2 + 32}}$ on 8 cores`, Test: tests.actor_blueprint_non_native_plonk_non_native_demo_test, SolanaProof: 'Signatures' },
//     { Name: `${tab}${tab}sha512_component`, Test: tests.blueprint_hashes_plonk_sha512_process_test },
//     { Name: `${tab}${tab}non_native_range_component`, Test: tests.blueprint_non_native_plonk_non_native_range_test },
//     { Name: `${tab}${tab}non_native_fixed_base_multiplication_component`, Test: tests.blueprint_non_native_plonk_fixed_base_mul_test },
//     { Name: `${tab}${tab}non_native_complete_addition_component `, Test: tests.blueprint_non_native_plonk_complete_addition_test },
//     { Name: `${tab}${tab}reduction_component`, Test: null },
//     { Name: `${tab}${tab}non_native_variable_base_multiplication_component`, Test: tests.blueprint_non_native_plonk_variable_base_multiplication_test },
//     // { Name: `${tab}${tab}non_native_variable_base_multiplication_component on 8 core`, Test: tests.actor_blueprint_non_native_plonk_variable_base_multiplication_test },
//     { Name: `${tab}${tab}${tab}non_native_variable_base_multiplication_per_bit_component`, Test: tests.blueprint_non_native_plonk_var_base_mul_per_bit_test },
//     { Name: emptyLine },
//     { Name: `${tab}Merkle_tree_component for the set $\{H_{B_{n_1}}, ..., H_{B_{n_2}}\}$`, Test: null, SolanaProof: 'State proof sequence maintenance' },
//     { Name: `${tab}${tab}sha256_component`, Test: tests.blueprint_hashes_plonk_sha256_process_test },
//     { Name: emptyLine },
// ];

const tableRows = [
    { Name: 'Solana component for $M$ validators, multithreading on 8 cores', Test: null },
    { Name: emptyLine },
    { Name: 'for $i$ from $n_1 + 1$ to $n_2 + 32$' },
    { Name: `${tab}H_{B_i} = sha256_component`, Test: tests.actor_blueprint_hashes_plonk_sha256_process_test, SolanaProof: 'Bank hash' },
    { Name: emptyLine },
    { Name: 'for $j$ from $0$ to $M$:' },
    { Name: `${tab}Ed25519_component for $H_{B_{n_2 + 32}}$`, Test: tests.actor_blueprint_non_native_plonk_non_native_demo_test, SolanaProof: 'Signatures' },
    { Name: `${tab}${tab}sha512_component`, Test: tests.actor_blueprint_hashes_plonk_sha512_process_test },
    { Name: `${tab}${tab}non_native_range_component`, Test: tests.actor_blueprint_non_native_plonk_non_native_range_test },
    { Name: `${tab}${tab}non_native_fixed_base_multiplication_component`, Test: tests.actor_blueprint_non_native_plonk_fixed_base_mul_test },
    { Name: `${tab}${tab}non_native_complete_addition_component `, Test: tests.actor_blueprint_non_native_plonk_complete_addition_test },
    { Name: `${tab}${tab}reduction_component`, Test: null },
    { Name: `${tab}${tab}non_native_variable_base_multiplication_component`, Test: tests.actor_blueprint_non_native_plonk_variable_base_multiplication_test },
    { Name: `${tab}${tab}${tab}non_native_variable_base_multiplication_per_bit_component`, Test: tests.actor_blueprint_non_native_plonk_var_base_mul_per_bit_test },
    { Name: emptyLine },
    { Name: `${tab}Merkle_tree_component for the set $\{H_{B_{n_1}}, ..., H_{B_{n_2}}\}$`, Test: null, SolanaProof: 'State proof sequence maintenance' },
    { Name: `${tab}${tab}sha256_component`, Test: tests.actor_blueprint_hashes_plonk_sha256_process_test },
    { Name: emptyLine },
];

function drawTable () {
    return asTable.configure(asTableConfig)(tableRows.map(drawTableRow));
};

function drawTableRow({Name, Test, SolanaProof}) {
    if (Test === undefined) {
        return { Name };
    }

    if (Test === null) {
        return {
            Name,
            SolanaProof,
            Time: noData,
            Preprocessor: noData,
            Private_preprocessor: noData,
            Permutation_argument: noData,
            Gate_argument: noData,
            Quotient_argument: noData,
            Polynomial_commitment_evaluation: noData,
            Status: noData,
            // Verification_Gas: noData
        }
    }

    return {
        Name,
        SolanaProof,
        Time: Test.time_execution,
        Preprocessor: Test.preprocessor,
        Private_preprocessor: Test.private,
        Permutation_argument: Test.permutation,
        Gate_argument: Test.gate,
        Quotient_argument: Test.quotient,
        Polynomial_commitment_evaluation: Test.polynomial,
        Status: 'Done',
        // Verification_Gas: noData,
    };
};

console.log(drawTable());
