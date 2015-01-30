*Everything should be built top-down, except the first time 1. Alan
Perlis*

RSpec-Varys automatically generates RSpec specs from your mocked methods each time your suite is run.

This enables you to build your program from the top-down (or outside-in if
your prefer) without having to manually keep track of which mocks have
been validated.

Installation instructions can be found [here](https://github.com/ritchiey/rspec-varys).

  A typical workflow using rspec-varys looks like this. Note, I haven't
written "and run your specs again" at the end of each step, that's
implied.

  - if you have no failing specs and you need some new functionality, write a new top-level spec.

  - if your specs are failing because your **spec** calls a non-existent function,  
      write the code for that function. Feel free to call methods that
      don't exist yet.

  - if your specs are failing because your **code** calls a non-existent function
      stub that function out in the spec using `allow`.

  - if your specs pass but varys generates new specs for untested stubs,
      copy the generated specs into the appropriate spec file.

  - if varys warns you about unneeded specs, delete those specs and any
      code that can be removed without making other specs fail.

  - if your specs pass but there are pending specs, pick one and remove
      the `pending` statement.

