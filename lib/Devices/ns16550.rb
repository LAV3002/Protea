require_relative "../SDL/plod"

module Devices

  Device(:ns16550) {

    Register(:rbr) {
      size 0x1
      offset 0x0
      type :ro
      enableIf {
        let :tmp, :b1, lsr.dlab
      }
    }

    Register(:thr) {
      size 0x1
      offset 0x0
      type :wo
      # enableIf lsr.DLAB == 0
    }

    Register(:ier) {
      size 0x1
      offset 0x1
      # enableIf lsr.DLAB == 0
    }

    Register(:iir) {
      size 0x1
      offset 0x2
      type :ro
    }

    Register(:fcr) {
      size 0x1
      offset 0x2
      type :wo
    }

    Register(:lcr) {
      size 0x1
      offset 0x3
    }

    Register(:mcr) {
      size 0x1
      offset 0x4
    }

    Register(:lsr) {
      size 0x1
      offset 0x5
      field :dlab, 0x7
    }

    Register(:msr) {
      size 0x1
      offset 0x6
    }

    Register(:scr) {
      size 0x1
      offset 0x7
    }

    Register(:dll) {
      size 0x1
      offset 0x0
      # enableIf lsr.DLAB == 1
    }

    Register(:dlm) {
      size 0x1
      offset 0x1
      # enableIf lsr.DLAB == 1
    }

    # Function(:lol, int(:lol), bv(64, :dom), void) {

    # }
    
    
  }

end
