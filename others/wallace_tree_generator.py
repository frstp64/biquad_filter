
# coding: utf-8

# In[2]:


import math
import numpy as np
def layer_reduction(old_layer):
    new_layer = [0 for i in range(len(old_layer)+1)]
    for i in reversed(range(len(old_layer))):
        new_layer[i] += old_layer[i] // 3 + (old_layer[i] % 3) // 2
        new_layer[i+1] += old_layer[i] // 3 + (old_layer[i] % 3) // 2 + (old_layer[i] % 3) % 2
    
    return np.trim_zeros(new_layer)
            
            

def wallace_level_finder(bit_number):
    current_bit_numbers = list(i+1 for i in range(bit_number)) + list(i+1 for i in reversed(range(bit_number-1)))
    number_reduction_layers = 0
    while max(current_bit_numbers) > 2:
        number_reduction_layers += 1
        current_bit_numbers = layer_reduction(current_bit_numbers)
    return number_reduction_layers

def generate_header(bit_number):
    '''Generates the textual header for the VHDL file.'''
    return f"""
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity unsigned_multiplier is
PORT(
input_A : IN  std_logic_vector({bit_number}-1 downto 0);
input_B : IN  std_logic_vector({bit_number}-1 downto 0);
clk : IN  std_logic;
reset : IN  std_logic;
en : IN  std_logic;
output : OUT  std_logic_vector({bit_number}-1 downto 0)
);
end unsigned_multiplier;

architecture wallace_tree of unsigned_multiplier is

"""

def generate_footer():
    """Generates the footer content for the VHDL file."""
    return """
end wallace_tree;"""

def generate_modules_declaration(modules_list):
    """Generates the modules declaration for the VHDL file."""
    content = """"""
    declarations = []
    for module in modules_list:
        new_declaration = module.get_declaration_string()
        if new_declaration not in declarations:
            declarations.append(new_declaration)
            content += module.get_declaration_string()
    return content

def generate_modules_instanciation(modules_list):
    """Generates the modules instanciation for the VHDL file."""
    content = """"""
    for module in modules_list:
        content += module.get_instanciation_string()
    return content

def generate_signals_declaration(signals_list):
    """Generates the signals declaration for the VHDL file."""
    content = """"""
    for signal in signals_list:
        content += signal.get_instanciation_string()
    return content

class Signal():
    def __init__(self, name, layer_number, bit_weight):
        self.name = name
        self.layer_number = layer_number
        self.bit_weight = bit_weight
        
    def get_instanciation_string(self):
        content = """"""
        content += f'signal {self.name}: std_logic;\n'
        return content
    
    def get_instance(self):
        return self.name
    
    def get_truncated_name(self):
        return str(id(self))
    
    def get_layer_number(self):
        return self.layer_number
    
    def get_weight(self):
        return self.bit_weight
    
    def pass_to_next_layer(self):
        self.layer_number += 1

class Vector():
    def __init__(self, name, length):
        self.name = name
        self.length = length
        self.bits = list(Signal('\'0\'', 0, 2**i) for i in range(length))
    
    def get_instance(self):
        return self.name
    
    def get_instanciation_string(self):
        content = """"""
        content += f'signal {self.name}: std_logic_vector({self.length-1} downto 0);\n'
        return content
    def add_bit(self, new_bit):
        self.bits[round(math.log(new_bit.get_weight(), 2))] = new_bit
        
    def get_concatenation_string(self):
        content = ''
        if 'output' in self.name:
            return content
        
        content += f'{self.get_instance()} <= '
        for asignal in reversed(self.bits):
            content += asignal.get_instance()
            content += ' & '
        content = content[:-2]
        content += ';\n'
        return content
class AndGate():
    def __init__(self, input_a, input_b, output):
        self.input_a = input_a
        self.input_b = input_b
        self.output = output
    
    def get_string(self):
        return f'{self.output.get_instance()} <= {self.input_a} and {self.input_b};\n'
    
class FA():
    def __init__(self, bit_a, bit_b, bit_c, sum_sig, carry_sig):
        self.bit_a = bit_a
        self.bit_b = bit_b
        self.bit_c = bit_c
        self.sum_sig = sum_sig
        self.carry_sig = carry_sig
    
    def get_declaration_string(self):
        return '''COMPONENT FA
Port ( bit_a : in  STD_LOGIC;
bit_b : in STD_LOGIC;
bit_c : in STD_LOGIC;
sum_sig : out  STD_LOGIC;
carry_sig: out STD_LOGIC
);
END COMPONENT;

'''
    
    def get_instanciation_string(self):
        return f'''FA_{self.sum_sig.get_truncated_name()}_{self.carry_sig.get_truncated_name()}: FA 
PORT MAP (
    bit_a => {self.bit_a.get_instance()},
    bit_b => {self.bit_b.get_instance()},
    bit_c => {self.bit_c.get_instance()},
    sum_sig => {self.sum_sig.get_instance()},
    carry_sig => {self.carry_sig.get_instance()}
);

'''
        
class HA():
    def __init__(self, bit_a, bit_b, sum_sig, carry_sig):
        self.bit_a = bit_a
        self.bit_b = bit_b
        self.sum_sig = sum_sig
        self.carry_sig = carry_sig
        
    def get_declaration_string(self):
        return '''COMPONENT HA
Port (
    bit_a : in  STD_LOGIC;
    bit_b : in STD_LOGIC;
    sum_sig : out  STD_LOGIC;
    carry_sig: out STD_LOGIC
);
END COMPONENT;

'''
    
    def get_instanciation_string(self):
        return f'''HA_{self.sum_sig.get_truncated_name()}_{self.carry_sig.get_truncated_name()}: HA 
PORT MAP (
    bit_a => {self.bit_a.get_instance()},
    bit_b => {self.bit_b.get_instance()},
    sum_sig => {self.sum_sig.get_instance()},
    carry_sig => {self.carry_sig.get_instance()}
);

'''

class Adder():
    def __init__(self, bit_number, input_a, input_b, output_vec):
        self.bit_number = bit_number
        self.input_a = input_a
        self.input_b = input_b
        self.output_vec = output_vec
        
        
    def get_declaration_string(self):
         return '''COMPONENT signed_adder
 generic ( SIGNAL_LENGTH: positive);
 PORT(
    input_A : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
    input_B : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
    clk : IN  std_logic;
    reset : IN  std_logic;
    en : IN  std_logic;
    output : OUT  std_logic_vector(SIGNAL_LENGTH-1 downto 0)
);
END COMPONENT;
'''
    
    def get_instanciation_string(self):
        return f'''Adder_final: signed_adder 
GENERIC MAP (
    SIGNAL_LENGTH => {self.bit_number}
)
PORT MAP (
    input_A => {self.input_a.get_instance()},
    input_B => {self.input_b.get_instance()},
    clk     => clk,
    reset   => reset,
    en      => en,
    output  => {self.output_vec.get_instance()}
);

'''
        
def extract_initial_multiplication_diamond(bit_number, signals_list, ands_list):
    '''Generates the initial multiplication diamond for the vhdl file
    For example, the 4-bit multiplication diamond looks like this:
              ****
             ****
            ****
           ****
    '''
    for input_a_weight in range(bit_number):
        for input_b_weight in range(bit_number):
            and_signal_weight = 2**(input_a_weight + input_b_weight)
            and_signal = Signal(f'a{input_a_weight}_and_b{input_b_weight}', 0, and_signal_weight)
            new_and = AndGate(f'input_a({input_a_weight})', f'input_b({input_b_weight})', and_signal)
            ands_list.append(new_and)
            signals_list.append(and_signal)

def generate_and_gates(ands_list):
    content = """"""
    for and_gate in ands_list:
        content += and_gate.get_string()
    return content
            
def generate_wallace_layer(bit_number, modules_list, signals_list, current_layer_number):
    relevant_signals = list(filter(lambda x: x.get_layer_number() == current_layer_number-1, signals_list))
    for current_weight in map(lambda x: 2**x, range(bit_number*2+1)):
        signals_with_relevant_weight = list(filter(lambda x: x.get_weight() == current_weight, relevant_signals))
        while len(signals_with_relevant_weight) > 0:
            if len(signals_with_relevant_weight) >= 3:
                bit_1 = signals_with_relevant_weight.pop(0)
                bit_2 = signals_with_relevant_weight.pop(0)
                bit_3 = signals_with_relevant_weight.pop(0)
                new_sum_sig = Signal(f'sum_layer{current_layer_number}_{bit_1.get_truncated_name()}_{bit_2.get_truncated_name()}_{bit_3.get_truncated_name()}',
                                     current_layer_number,
                                     current_weight)
                new_carry_sig = Signal(f'carry_layer{current_layer_number}_{bit_1.get_truncated_name()}_{bit_2.get_truncated_name()}_{bit_3.get_truncated_name()}',
                                     current_layer_number,
                                     current_weight*2)
                
                new_module = FA(bit_1, bit_2, bit_3, new_sum_sig, new_carry_sig);
                
                signals_list.append(new_sum_sig)
                signals_list.append(new_carry_sig)
                modules_list.append(new_module)
                
            elif len(signals_with_relevant_weight) == 2:
                bit_1 = signals_with_relevant_weight.pop(0)
                bit_2 = signals_with_relevant_weight.pop(0)
                new_sum_sig = Signal(f'sum_layer{current_layer_number}_{bit_1.get_truncated_name()}_{bit_2.get_truncated_name()}',
                                     current_layer_number,
                                     current_weight)
                new_carry_sig = Signal(f'carry_layer{current_layer_number}_{bit_1.get_truncated_name()}_{bit_2.get_truncated_name()}',
                                     current_layer_number,
                                     current_weight*2)
                new_module = HA(bit_1, bit_2, new_sum_sig, new_carry_sig);
                
                signals_list.append(new_sum_sig)
                signals_list.append(new_carry_sig)
                modules_list.append(new_module)
            else: # one signal only, we pass it to the next layer
                bit_1 = signals_with_relevant_weight.pop(0)
                bit_1.pass_to_next_layer()

def generate_final_sum_layer(bit_number, modules_list, signals_list, reduction_layer_number):
    # map the bit signals to std_logic_vectors
    relevant_signals = list(filter(lambda x: x.get_layer_number() == reduction_layer_number, signals_list))
    first_vector = Vector('first_vector', bit_number**2)
    second_vector = Vector('second_vector', bit_number**2)
    output_vector = Vector('output_vector', bit_number**2)
    for current_weight in map(lambda x: 2**x, range(bit_number*2+1)):
        signals_with_weight = list(filter(lambda x: x.get_weight() == current_weight, relevant_signals))
        if len(signals_with_weight) > 2:
            raise Exception("Too many signals!!!")
        elif len(signals_with_weight) == 2:
            first_vector.add_bit(signals_with_weight[0])
            second_vector.add_bit(signals_with_weight[1])
        elif len(signals_with_weight) == 1:
            first_vector.add_bit(signals_with_weight[0])
    
    new_adder = Adder(bit_number**2, first_vector, second_vector, output_vector)
    modules_list.append(new_adder)
    signals_list.append(first_vector)
    signals_list.append(second_vector)
    signals_list.append(output_vector)
            
def generate_vector_concatenation(signals_list):
    content = ''''''
    for signal in signals_list:
        if isinstance(signal, Vector):
            content += signal.get_concatenation_string()
    return content

def generate_final_output_mapping(bit_number):
    return f'''output <= output_vector({bit_number}-1 downto 0);
'''

def generate_wallace_code(bit_number):
    modules_list = []
    signals_list = []
    ands_list = []
    
    extract_initial_multiplication_diamond(bit_number, signals_list, ands_list)
    reduction_layer_number = wallace_level_finder(bit_number)
    for current_reduction_layer in range(1, reduction_layer_number+1):
        generate_wallace_layer(bit_number, modules_list, signals_list, current_reduction_layer)
    generate_final_sum_layer(bit_number, modules_list, signals_list, reduction_layer_number)
    
    content = """"""
    content += generate_header(bit_number)
    content += generate_modules_declaration(modules_list)
    content += generate_signals_declaration(signals_list)
    content += '\nbegin\n'
    content += generate_modules_instanciation(modules_list)
    content += generate_and_gates(ands_list)
    content += generate_vector_concatenation(signals_list)
    content += generate_final_output_mapping(bit_number)
    content += generate_footer()
    return content

bit_number = 18
print(generate_wallace_code(bit_number))

