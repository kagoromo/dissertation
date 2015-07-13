import Control.LVish
import qualified Control.Par.ST as PST
import qualified Control.Par.ST.Vec as V
import Data.Vector (freeze, toList)

p :: (HasGet e, HasPut e) => V.ParVecT s1 String Par e s [String]
p = do
  -- Fill all six slots in the vector with "foo".
  V.set "foo"
  -- Get a pointer to the state.
  ptr <- V.reify

  -- Fork two computations, each of which has access to half the
  -- vector.  Within the two forked child computations, `ptr` is
  -- inaccessible.
  V.forkSTSplit 3 -- Split at index 3 in the vector.
                (V.write 0 "bar")
                (V.write 0 "baz")

  frozen <- PST.liftST (freeze ptr)
  return (toList frozen)

main = print (runPar (V.runParVecT 6 p))
