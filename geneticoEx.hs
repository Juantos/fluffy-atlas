import AGenetico
import Fitness
import Generador


--PARÁMETROS DEL ALGORITMO GENÉTICO
numIteraciones :: Int --criterio de parada del algoritmo genético 
numIteraciones = 10000

poblacion :: Int --número de cromosomas que se evalúan en cada iteración (múltiplo de 100)
poblacion = 100

data TipoCromosoma = ValuesInRange | Permutation --valores posibles "ValuesInRange" "Permutation"
tCromosoma :: TipoCromosoma
tCromosoma = Permutation

tamanoCromosoma :: Int --length de la lista que representa al cromosoma
tamanoCromosoma = 9  --valores para el ejemplo del cuadrado mágico

valoresGenRange :: (Int,Int) --valor mínimo y máximo que puede tomar un gen en el cromosoma (para ValuesInRange)
valoresGenRange = (1,9)

valoresGenPermutation :: [Int]
valoresGenPermutation = [1..9] --valores para el ejemplo del cuadrado mágico

porcentajeMezcla :: [(String,Int)] --Describe que mutaciones y combinaciones utilizar y en qué porcentaje
porcentajeMezcla = [("padres",20),("comb1",50),("comb2",1),("combCiclos",70),("mut1",1),("mutInter",5),("mutInser",5)]

data Objetivo = Max | Min  --Objetivo de la funcion
obj :: Objetivo
obj = Min

data MetodoSeleccion = Elitista | Ruleta  --Metodo de selección utilizado por el algoritmo
                                        deriving Eq  
mSeleccion :: MetodoSeleccion
mSeleccion = Elitista

fitness :: ([Int]->Double)
fitness = fitnessCuadradoMagico



--Cuando trabajamos con cromosomas de tipo Permutation, solo podemos utilizar combinaciones y mutaciones que alteren las posiciones de los genes sin que el conjunto de valores cambie
--La suma de los porcentajes debe ser 100


itera :: IO [[Int]] -> TipoCromosoma -> Objetivo -> IO [[Int]]
itera xs Permutation Min = do
    lista <- xs
    randomPoblacion <- randIntRango 0 (poblacion-1)
    randomPadres <- randIntRango 0 ((snd (porcentajeMezcla!!0))-1)
    randomRange <- randIntRango (fst valoresGenRange) (snd valoresGenRange)
    randomTamCromosoma <- randIntRango 0 (tamanoCromosoma-1)
    --let listaTuplas = zip lista (map fitness lista)
    let padres = seleccionElitistaMinimizar lista ((snd (porcentajeMezcla!!0))) fitness 
    --let padres = [seleccionRuletaAux listaTuplas (fromIntegral randomRuleta) 0.0 | x <- [1..((snd (porcentajeMezcla!!0)))]]
    let comb1 = [combinacion1 (padres!!randomPadres) (padres!!randomPadres) randomTamCromosoma | x <- [1..((snd (porcentajeMezcla!!1)))]]
    let comb2 = [combinacion2 (padres!!randomPadres) (padres!!randomPadres) | x <- [1..((snd (porcentajeMezcla!!2)))]]
    let combCiclos = [combinacionCiclos (padres!!randomPadres) (padres!!randomPadres) randomTamCromosoma | x <- [1..((snd (porcentajeMezcla!!3)))]]
    let mut1 = [mutacion1 (padres!!randomPadres) randomTamCromosoma randomRange | x <- [1..((snd (porcentajeMezcla!!4)))]]
    let mutInter = [permutacioninter (padres!!randomPadres) randomTamCromosoma randomTamCromosoma | x <- [1..((snd (porcentajeMezcla!!5)))]]
    let mutInser = [permutacioninser (padres!!randomPadres) randomTamCromosoma randomTamCromosoma | x <- [1..((snd (porcentajeMezcla!!6)))]] 
    return (padres++comb1++comb2++combCiclos++mut1++mutInter++mutInser)

--PROBLEMA ACTUAL: necesitamos declarar una barbaridad de numeros aleatorios
 
--prueba: itera (generaPoblacionPermutation [1..9] 100) Permutation Min



--pruebaElitista :: IO [[Int]]
--pruebaElitista = do
--   let r = seleccionElitistaMinimizar ([[3,5,6,7,8,1,4,9,2],[1,8,2,6,9,4,7,3,5],[7,2,6,1,3,8,9,4,5],[6,4,3,2,8,5,9,7,1],[7,3,4,9,6,5,1,8,2],[4,8,1,6,3,7,9,5,2],[6,9,2,3,8,4,7,5,1],[1,2,9,5,6,4,7,8,3],[1,8,7,4,2,5,9,6,3]]) 2 fitnessCuadradoMagico
--   return r

