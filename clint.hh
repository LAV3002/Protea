#pragma once

#include "arch/riscv/system.hh"
#include "cpu/base.hh"
#include "mem/packet.hh"
#include "mem/packet_access.hh"
#include "sim/system.hh"
#include "arch/riscv/interrupts.hh"
#include "dev/intpin.hh"
#include "dev/io_device.hh"
#include "dev/mc146818.hh"
#include "dev/reg_bank.hh"
#include "mem/packet.hh"
#include "mem/packet_access.hh"
#include "sim/system.hh"


namespace protea {
  auto _or(auto lhs, auto rhs) {
    return lhs | rhs;
  }

  auto _mul(auto lhs, auto rhs) {
    return lhs * rhs;
  }

  auto _add(auto lhs, auto rhs) {
    return lhs + rhs;
  }

  auto _and(auto lhs, auto rhs) {
    return lhs & rhs;
  }

  auto _eq(auto lhs, auto rhs) {
    return lhs == rhs;
  }

  auto _sub(auto lhs, auto rhs) {
    return lhs - rhs;
  }

  auto _gt(auto lhs, auto rhs) {
    return lhs > rhs;
  }

  auto _not(auto op) {
    return ~op;
  }

  bool _cast(auto op) {
    return op > 0;
  }

  template <typename BVTD, typename BVTS>
  void _insert(BVTD& dist, uint32_t lsb, uint32_t size, BVTS src) {
    BVTD cleaner = ~((((BVTD)1 << size) - 1) << lsb);
    BVTS data = ((BVTD)src & (((BVTD)1 << size) - 1)) << lsb;

    dist &= cleaner;
    dist |= data;
  }

  template <typename BVT>
  BVT _extract(BVT op, uint32_t lsb, uint32_t size) {
    return (op >> lsb) & (((BVT)1 << size) - 1);
  }
}

namespace gem5 {

class Terminal;
class Platform;

class Clint : public Uart {

    

    int int_rtc = 0;
    int int_reset = 1;
    int int_timer_machine = 7;
    int int_software_machine = 3;

    std::function<void()> lambda_0 = [this] (bool newVal) {
        if (newVal) {
            doReset();
        }
    };


    auto resetLambda = lambda_0;
    System* system;
    uint32_t nThread;
    IntSinkPinClint signal;
    SignalSinkPortBool reset;
    bool resetMtimecmp;
    uint64_t resetValue;

    std::array<uint32_t, 4096> msip;
    std::array<uint64_t, 4096> mtimecmp;
    uint64_t mtime = 0;

    void msip_write(uint32_t data, int cid) {
        msip[cid] = data;
        update(cid);
    }
    
    void msip_update(int cid) {
        
        Threads& _tmp18 = system->threads;
        ThreadContext* _tmp19;
        _tmp19 = _tmp18[cid];
        ThreadContext* tc;
        tc = _tmp19;
        Clint::msip _tmp20;
        unsupported
        if (_tmp20) {
            BaseCPU* _tmp21;
            _tmp21 = tc->getCpuPtr();
            tc->threadId();
            _tmp21->postInterrupt(threadId, int_software_machine, 0);
        }
        else {
            BaseCPU* _tmp22;
            _tmp22 = tc->getCpuPtr();
            tc->threadId();
            _tmp22->clearInterrupt(threadId, int_software_machine, 0);
        }
    }
    
    uint8_t msip_read() { return msip; }
    
    
    
    uint8_t mtimecmp_read() { return mtimecmp; }
    
    void mtimecmp_write(uint8_t data) { mtimecmp = data; }
    
    
    
    uint8_t mtime_read() { return mtime; }
    
    void mtime_write(uint8_t data) { mtime = data; }
    


public:

    void ctor(ClintParams params) {
        params.system();
        Init(system, system);
        
        b32& _tmp0 = params.num_threads;
        Init(nThread, _tmp0);
        
        str& _tmp1 = params.name;
        
        _tmp2 = protea::_add(_tmp1, );
        Init(signal, _tmp2, 0, mtime, int_rtc);
        
        str& _tmp3 = params.name;
        
        _tmp4 = protea::_add(_tmp3, );
        Init(reset, _tmp4);
        
        bool& _tmp5 = params.reset_mtimecmp;
        Init(resetMtimecmp, _tmp5);
        
        b64& _tmp6 = params.mtimecmp_reset_value;
        Init(resetValue, _tmp6);
        reset.onChange(resetLambda);
    }
    
    void raiseInterruptPin(int id) {
        uint8_t _tmp7;
        _tmp7 = protea::_eq(id, int_rtc);
        if (_tmp7) {
            Clint::mtime_seq _tmp9;
            _tmp9 = protea::_add(mtime, 1);
            mtime = _tmp9;
        }
        int cid;
        unsupported
    }
    
    void init() {
        int cid;
        unsupported
    }
    
    void doReset() {
        mtime = 0;
        int cid;
        unsupported
        raiseInterruptPin(int_reset);
    }


    Clint(const ClintParams &p)
      : Uart(p, p.pio_size) {}

    Tick read(PacketPtr pkt) override {
      uint64_t daddr = pkt->getAddr() - pioAddr;
      uint8_t data = 0;

      switch (daddr) {
        case 0:
          data = msip_read();
          break;
        case 16384:
          data = mtimecmp_read();
          break;
        case 49144:
          data = mtime_read();
          break;
        default:
          data = 0;
      }


      *pkt->getPtr<uint8_t>() = data;

      pkt->makeAtomicResponse();
      return pioDelay;
    }

    Tick write(PacketPtr pkt) {
      Addr daddr = pkt->getAddr() - pioAddr;
      uint8_t data = *pkt->getPtr<uint8_t>();

      switch (daddr) {
        case 0:
          msip_write(data);
          break;
        case 16384:
          mtimecmp_write(data);
          break;
        case 49144:
          mtime_write(data);
          break;
        default:
          break;
      }


      pkt->makeAtomicResponse();
      return pioDelay;
    }

    AddrRangeList getAddrRanges() const
    {
        AddrRangeList ranges;
        ranges.push_back(RangeSize(pioAddr, pioSize));
        return ranges;
    }

    void serialize(CheckpointOut &cp) const override {}
    void unserialize(CheckpointIn &cp) override {}

};

}
