# Include all rules
all

# Customize rules below
rule 'MD007', :indent => 4
rule 'MD026', :punctuation => '.,;:!' # question mark character excluded

# Ignore rules below
exclude_rule 'MD001' # Heading levels should only increment by one level at a time
exclude_rule 'MD013' # Line length
exclude_rule 'MD041' # First line in file should be a top level heading
