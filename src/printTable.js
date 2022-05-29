const asTable = require('as-table');
const fs = require("fs");
const file = 'time.log';

let text = fs.readFileSync(file).toString().trim();
text = text.split("\n");

const tests = {
    'blueprint_hashes_plonk_decomposition_test': text[0],
    'blueprint_non_native_plonk_non_native_range_test': text[1],
    'blueprint_non_native_plonk_var_base_mul_per_bit_test': text[2],
    'blueprint_non_native_plonk_field_mul_test': text[3],
    'blueprint_non_native_plonk_complete_addition_test': text[4],
    'blueprint_non_native_plonk_field_sub_test': text[5],
    'blueprint_non_native_plonk_field_add_test': text[6]
};

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

const tableRows = [
    { Name: 'Solana component for $M$ validators', Test: null },
    { Name: emptyLine },
    { Name: 'for $i$ from $n_1 + 1$ to $n_2 + 32$' },
    { Name: `${tab}H_{B_i} = sha_256_component`, Test: null, SolanaProof: 'Bank hash' },
    { Name: `${tab}${tab}decomposition_component`, Test: tests.blueprint_hashes_plonk_decomposition_test },
    { Name: `${tab}${tab}sha_256_process_component`, Test: null },
    { Name: emptyLine },
    { Name: 'for $j$ from $0$ to $M$:' },
    { Name: `${tab}Ed25519_component for $H_{B_{n_2 + 32}}$`, Test: null, SolanaProof: 'Signatures' },
    { Name: `${tab}${tab}non_native_range_component`, Test: tests.blueprint_non_native_plonk_non_native_range_test },
    { Name: `${tab}${tab}sha_512_component`, Test: null },
    { Name: `${tab}${tab}${tab}decomposition_component `, Test: tests.blueprint_hashes_plonk_decomposition_test },
    { Name: `${tab}${tab}${tab}sha_512_process_component`, Test: null },
    { Name: `${tab}${tab}non_native_fixed_base_multiplication_component`, Test: null },
    { Name: `${tab}${tab}non_native_complete_addition_component `, Test: tests.blueprint_non_native_plonk_complete_addition_test },
    { Name: `${tab}${tab}reduction_component`, Test: null },
    { Name: `${tab}${tab}non_native_variable_base_multiplication_component`, Test: null },
    { Name: `${tab}${tab}${tab}non_native_variable_base_multiplication_per_bit_component`, Test: tests.blueprint_non_native_plonk_var_base_mul_per_bit_test },
    { Name: emptyLine },
    { Name: `${tab}Merkle_tree_component for the set $\{H_{B_{n_1}}, ..., H_{B_{n_2}}\}$`, Test: null, SolanaProof: 'State proof sequence maintenance' },
    { Name: `${tab}${tab}sha_256_component`, Test: null },
    { Name: `${tab}${tab}${tab}decomposition_component `, Test: tests.blueprint_hashes_plonk_decomposition_test },
    { Name: `${tab}${tab}${tab}sha_256_process_component  `, Test: null },
    { Name: emptyLine },
    { Name: 'Each non-native component contains:' },
    { Name: `${tab}non_native_multiplication component`, Test: tests.blueprint_non_native_plonk_field_mul_test },
    { Name: `${tab}non_native_addition_component`, Test: tests.blueprint_non_native_plonk_field_add_test },
    { Name: `${tab}non_native_subtraction_component`, Test: tests.blueprint_non_native_plonk_field_sub_test },
    { Name: `${tab}non_native_range_conponent`, Test: tests.blueprint_non_native_plonk_non_native_range_test },
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
            Status: noData,
            Verification_Gas: noData
        }
    }

    return {
        Name,
        SolanaProof,
        Time: Test.split(" ")[1],
        Status: 'Done',
        Verification_Gas: noData,
    };
};

console.log(drawTable());
