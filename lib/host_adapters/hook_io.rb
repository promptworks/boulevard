require_relative '../boulevard/crypt'

code_package = Hook['params'].fetch('__code_package__')

code = Boulevard::Crypt.new($secret_key).unpackage(code_package)

eval code