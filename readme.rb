#! /usr/bin/env ruby

template = <<-__
  NAME
    arrayfields.rb

  URIS
    http://rubyforge.org/projects/codeforpeople/

  SYNOPSIS
      require 'arrayfields'

      a = Arrayfields.new :k, :v, :a, :b

      p a[:k]        #=> :v
      p a[:a]        #=> :b
      p a.fields     #=> [:k, :a]
      p a.values     #=> [:v, :b]
      p a            #=> [:v, :b]
      p a.to_hash    #=> {:k => :v, :a => :b} 
      p a.pairs      #=> [[:k, :v], [:a, :b]]

      a[:foo] = :bar

      p a[:foo]      #=> :bar
      p a.fields     #=> [:k, :a, :foo]

   AND

      require 'arrayfields'  

      fields = 'name', 'age'
      a = [ 'zaphod', 42 ]

      a.fields = fields

      a['name']                #=> 'zaphod'
      a[:name ]                #=> 'zaphod'
      a.indices 'name', 'age'  #=> [ 'zaphod', 42 ]

  DESCRIPTION
    allow keyword access to array instances.  arrayfields works by adding only a
    few methods to arrays, namely #fields= and fields, but the #fields= method is
    hooked to extend an array on a per object basis.  in otherwords __only__ those
    arrays whose fields are set will have auto-magical keyword access bestowed on
    them - all other arrays remain unaffected.  arrays with keyword access require
    much less memory when compared to hashes/objects and yet still provide fast
    lookup and preserve data order.

  LIST OF OVERRIDDEN METHODS
    Array#[]
    Array#slice
    Array#[]=
    Array#at
    Array#delete_at
    Array#fill
    Array#values_at
    Array#indices
    Array#indexes
    Array#slice!

  LIST OF HASH-LIKE METHODS
    Array#each_with_field
    Array#each_pair
    Array#each_key
    Array#each_value
    Array#fetch
    Array#has_key?
    Array#member?
    Array#key?
    Array#has_value?
    Array#value?
    Array#keys
    Array#store
    Array#values
    Array#to_hash
    Array#to_h
    Array#update
    Array#replace
    Array#invert
    Array#pairs

  LIST OF ADDED Array METHODS
    Array#fields=
    Array#fields

  LIST OF ADDED Array CLASS METHODS
    Array.fields/Array.struct

  SAMPLES
    <%= samples %>

  AUTHOR
    ara.t.howard@gmail.com

  HISTORY
    4.7.4
      - fixes for clone/dup methods

    4.6.0
      - Array#fields getter acts as setter if arg given, eg

          a = []

          a.fields %w( a b c )
          a['c'] = 42

    4.4.0:
      - working dup method worked in, also deepcopy and clone

    4.3.0:
      - a dup like method, named 'copy' and based on clone, is added to Arrayfields objects

    4.2.0:
      - a dup impl apparently caused some confusion with both rake and rails, so
        this release undoes that impl and should be considered a critical bugfix
        release

    4.1.0:
      - improved Array.struct method, see sample/e.rb

    4.0.0:
      - added Arrayfields.new(*arbitrary_evenly_numbered_list_of_objects)
      - added #to_pairs and #pairs
      - tried but failed to recall what happend for version 3.8
      - changed Array.fields to == Arrayfields.new (used to alias Array.struct)
      - added impl of Fieldable#dup that sets fields in dupped object

    3.7.0:
      - multiton pattern clean up, thanks gavin kistner!
      - mods for ruby 1.8.6 (alias bug in 1.8.6 i think)
      - added PseudoHash class
      - added Array.struct/fields class generator

    3.6.0:
      - made string/symbol keys interchangeable

          list = [0, 1, 2]
          list.fields = %w( a b c )
          p list['a'] #=> 0
          p list[:a] #=> 0
      

    3.5.0:
      - added more hash-like methods
        - update
        - replace
        - invert

    3.4.0:
      - added FieldedArray[] ctor
      - added methods to make Arrays with fields set behave more closely to Hashes
        - each_pair 
        - each_key
        - each_value
        - fetch
        - has_key?
        - member?
        - key?
        - has_value?
        - value?
        - keys?
        - store
        - values

    3.3.0:
      - added gemspec file - thnx Assaph Mehr
      - added FieldedArray proxy class which minimizes modifications to class
        Array and allow ArrayFields to work (potientially) other arraylike object.
        thnks Sean O'Dell
      - added ArrayFields#to_hash method - this seems like an obvious one to add!
      - remedied bug where using append feature of assigning with unknow field
        appedended but did not append to acutal fields
      - added samples
      - created rubyforge accnt @ http://rubyforge.org/projects/arrayfields/ 

    3.2.0:
      - precedence fix in many methods - thnx. nobu
      - test for #slice! were not being run - corrected
      - added test for appeding via "a['new_field'] = 42"

    3.1.0:
      - added FieldSet class to reduce ram - thnx. Kirk Haines for profiliing
        memory and prompting this change

      - interface changed every so slightly so

          a.fields = 'a', 'b', 'c'

        is not allowed.  use

          a.fields = %w(a b c) 

        or

          a.fields = ['a', 'b', 'c']


    3.0.0:
      - added unit tests
__


require 'erb'
require 'pathname'

$VERBOSE=nil

def indent(s, n = 2)
  s = unindent(s)
  ws = ' ' * n
  s.gsub(%r/^/, ws)
end

def unindent(s)
  indent = nil
  s.each do |line|
    next if line =~ %r/^\s*$/
    indent = line[%r/^\s*/] and break
  end
  indent ? s.gsub(%r/^#{ indent }/, "") : s
end

samples = ''
prompt = '~ > '

Dir.chdir(File.dirname(__FILE__))

Dir['sample*/*'].sort.each do |sample|
  samples << "\n" << "  <========< #{ sample } >========>" << "\n\n"

  cmd = "cat #{ sample }" 
  samples << indent(prompt + cmd, 2) << "\n\n" 
  samples << indent(`#{ cmd }`, 4) << "\n" 

  cmd = "ruby #{ sample }" 
  samples << indent(prompt + cmd, 2) << "\n\n" 

  cmd = "ruby -e'STDOUT.sync=true; exec %(ruby -Ilib #{ sample })'" 
  #cmd = "ruby -Ilib #{ sample }" 
  samples << indent(`#{ cmd } 2>&1`, 4) << "\n" 
end

erb = ERB.new(unindent(template))
result = erb.result(binding)
#open('README', 'w'){|fd| fd.write result}
#puts unindent(result)
puts result
