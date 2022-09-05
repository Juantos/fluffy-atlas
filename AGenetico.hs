

{-# OPTIONS_GHC -Wno-incomplete-patterns #-}
module AGenetico(
    combinacion1
    ,ejecutaCombinacion1
    ,combinacion2
    ,ejecutaCombinacion2
    ,combinacion2Aux
    ,combinacionCiclos
    ,ejecutaCombinacionCiclos
    ,combinacionCiclosAux
    ,mutacion1
    ,ejecutaMutacion1Int
    ,ejecutaPermutacionInter
    ,interludio
    ,permutacioninser
    ,ejecutaPermutacionInser
    ,posEnLista
    ,ciclo
    ,seleccionRuleta
    ,seleccionRuletaAux
    ,seleccionElitistaMaximizar
    ,seleccionElitistaMinimizar
    ,ordena
    

) where
import Data.List
import System.Random
import System.IO.Unsafe
import Generador
import System.Win32 (peekProcessEntry32)

--COMBINACIONES
--------------------------------------------------------------------------------------------------------------------------
--combinacion1 xs ys i = take i xs ++ drop i ys

--Input: lista con todos los padres, tamaño de cromosoma y el porcentaje de veces que se ejecutará esta combinación del total de mutaciones/combinaciones
--       n es el número de veces que queremos ejecutar combinación 1
--Proceso: coge un padre aleatorio y lo mezcla con otro padre aleatorio cortando cada uno según una posición generada aleatoriamente
--Output: la combinación de un padre aleatorio con otro también aleatorio
combinacion1 :: [[a]] -> Int -> Int -> Int -> IO [[a]]
combinacion1 _ _ _ 0 = return [] 
combinacion1 padres tC porcentaje n = do
    rp1 <- randIntRango 0 porcentaje
    rp2 <- randIntRango 0 porcentaje
    pos <- randIntRango 0 (tC-1)
    let c = take pos (padres!!rp1) ++ drop pos (padres!!rp2)
    cs <- combinacion1 padres tC porcentaje (n-1)
    return (c:cs)

--Hace muchas combinaciones teniendo en cuenta el porcentaje (snd (mezcla!!1)) de los mejores padres especificados
ejecutaCombinacion1 :: [[a]] -> Int -> [(String,Int)] -> IO [[a]]
ejecutaCombinacion1 padres tC mezcla = do
    let porcentaje = ((snd (mezcla!!0))-1)
    comb1 <- combinacion1 padres tC porcentaje ((snd (mezcla!!1)))
    return comb1


    
{- combinacion1 :: [a] -> [a] -> Int -> [a] --Recibe dos cromosomas y la posicion a partir de la cual termina el primero y comienza el segundo
combinacion1 xs ys i = combinacionAux xs ys i []
combinacion1Aux :: [a] -> [a] -> Int -> [a] -> [a]
combinacion1Aux [x] [y] i zs
    | i==0 = zs ++ [y]
    | otherwise = zs ++ [x]
    
combinacionAux (x:xs) (y:ys) i zs 
    |i==0 = combinacion1Aux xs ys 0 (zs++[y])
    |otherwise = combinacion1Aux xs ys (i-1) (zs++[x])
-}
--------------------------------------------------------------------------------------------------------------------------

--Input: lista con todos los padres y el porcentaje de veces que se ejecutará esta combinación del total de mutaciones/combinaciones
--       n es el número de veces que queremos ejecutar combinación2
--Proceso: coge un padre aleatorio y lo mezcla con otro padre aleatorio, alternando entre un gen de cada uno
--Output: la combinación de un padre aleatorio con otro también aleatorio

combinacion2Aux :: [a] -> [a] -> [a] -> Int -> [a]
combinacion2Aux [] [] zs _ =  zs
combinacion2Aux (x:xs) (y:ys) zs 0 = combinacion2Aux xs ys (zs++[x]) 1 --Alternador
combinacion2Aux (x:xs) (y:ys) zs 1 = combinacion2Aux xs ys (zs++[y]) 0 

combinacion2 :: [[a]] -> Int -> Int -> IO [[a]]
combinacion2 _ _ 0 = return []
combinacion2 padres porcentaje n = do
    rp1 <- randIntRango 0 porcentaje
    rp2 <- randIntRango 0 porcentaje
    let c = combinacion2Aux (padres!!rp1) (padres!!rp2) [] 0
    cs <- combinacion2 padres porcentaje (n-1)
    return (c:cs)

ejecutaCombinacion2 :: [[a]] -> [(String, Int)] -> IO [[a]]
ejecutaCombinacion2 padres mezcla = do
    let porcentaje = (snd (mezcla!!0))-1
    comb2 <- combinacion2 padres porcentaje (snd (mezcla!!2))
    return comb2


--------------------------------------------------------------------------------------------------------------------------

--Input: lista con todos los padres, tamaño de cromosoma y el porcentaje de veces que se ejecutará esta combinación del total de mutaciones/combinaciones
--       n es el número de combinaciones que queremos obtener
--Proceso: 
--Output: de entre todos los padres, uno mutado

combinacionCiclos :: Eq a => [[a]] -> Int -> Int -> Int -> IO [[a]] --Recibe dos cromosomas y un número aleatorio y devuelve un cromosoma nuevo utilizando el cruce basado en ciclos (para cromosomas en los que los elementos no pueden repetirse)
combinacionCiclos _ _ _ 0 = return []
combinacionCiclos padres tC porcentaje n = do
    rp1 <- randIntRango 0 porcentaje
    rp2 <- randIntRango 0 porcentaje
    rtc <- randIntRango 0 tC
    let p1 = padres!!rp1
    let p2 = padres!!rp2
    let c = combinacionCiclosAux p1 p2 (ciclo p1 p2 rtc []) []
    cs <- combinacionCiclos padres tC porcentaje (n-1)
    return (c:cs)

    --combinacionCiclosAux xs ys (ciclo xs ys i []) []

combinacionCiclosAux :: Eq a => [a] -> [a] -> [a] -> [a] -> [a] --Recibe los mismos cromosomas que la función anterior + la lista con el ciclo a utilizar y una lista vacia para la recursion
combinacionCiclosAux [] [] ciclos zs = zs
combinacionCiclosAux (x:xs) (y:ys) ciclos zs 
    | elem x ciclos = combinacionCiclosAux xs ys ciclos (zs ++ [x])
    | otherwise = combinacionCiclosAux xs ys ciclos (zs ++ [y])

ejecutaCombinacionCiclos :: Eq a => [[a]] -> Int -> [(String,Int)] -> IO [[a]]
ejecutaCombinacionCiclos padres tC mezcla = do
    let porcentaje = ((snd (mezcla!!0))-1)
    combi <- combinacionCiclos padres (tC-1) porcentaje (snd (mezcla!!3))
    return combi

     

--MUTACIONES
--------------------------------------------------------------------------------------------------------------------------


--Input: lista con todos los padres, tamaño de cromosoma y el porcentaje de veces que se ejecutará esta combinación del total de mutaciones/combinaciones
--       n es el número de veces que queremos ejecutar combinación 1
--Proceso: muta, de cada padre introducido, un gen aleatorio por otro valor aleatorio
--Output: padres mutados


mutacion1 :: [a] -> Int -> a -> [a]
mutacion1 xs pos a = (take pos xs) ++ [a] ++ (reverse (take ((length xs)-(pos+1)) (reverse xs)))

iteraMutacion1Int :: [[Int]] -> Int -> (Int, Int) -> Int -> Int -> IO [[Int]]
iteraMutacion1Int _ _ _ _ 0 = return []
iteraMutacion1Int padres tC valoresGenRange porcentaje n = do
    randomRange <- randIntRango (fst valoresGenRange) (snd valoresGenRange)
    rp <- randIntRango 0 porcentaje
    rtc <- randIntRango 0 tC
    let m = mutacion1 (padres!!rp) rtc randomRange
    ms <- iteraMutacion1Int padres tC valoresGenRange porcentaje (n-1)
    return (m:ms)

ejecutaMutacion1Int :: [[Int]] -> Int -> (Int,Int) -> [(String,Int)] -> IO [[Int]]
ejecutaMutacion1Int padres tC valoresGenRange mezcla = do
    let porcentaje = (snd (mezcla!!0))-1
    mut1 <- iteraMutacion1Int padres (tC-1) valoresGenRange porcentaje ((snd (mezcla!!4)))
    return mut1


-------------------------------------------------------------------------------------------------------------------------
--PERMUTACIÓN POR INTERCAMBIO: se intercambian los valores de dos posiciones aleatorias


--Input: lista con todos los padres, tamaño de cromosoma y el porcentaje de veces que se ejecutará esta combinación del total de mutaciones/combinaciones
--       n es el número de permutaciones que queremos obtener
--Proceso: muta, para un número de padres concreto (según el porcentaje asignado a esta permutación), el cromosoma
--          recibiendo dos posiciones e intercambiándolas de sitio
--Output: lista de padres mutados


intercambiaValores :: [a] -> Int -> Int -> [a]   --Recibe el cromosoma y las dos posiciones a intercambiar (importante introducir los numeros en orden)
intercambiaValores xs pos1 pos2 = (take pos1 xs) ++ [xs !! pos2] ++ (interludio xs pos1 pos2) ++ [xs !! pos1] ++ (drop (pos2+1) xs)
interludio :: [a] -> Int -> Int -> [a]
interludio xs pos1 pos2 = take (pos2-(pos1+1)) (drop (pos1+1) xs)


permutacionIntercambio :: [a] -> Int -> IO [a]
permutacionIntercambio padre tC = do
    rtc1 <- randIntRango 0 (tC)
    rtc2 <- randIntRango 0 (tC)
    if rtc1 < rtc2 --comprueba qué posición es menor
        then do
            let r = intercambiaValores padre rtc1 rtc2
            return r
        else do
            if rtc1 > rtc2
                then do
                    let r = intercambiaValores padre rtc2 rtc1
                    return r
                else do
                    return padre

iteraPermutaIntercambios :: [[a]] -> Int -> Int -> Int -> IO [[a]]
iteraPermutaIntercambios _ _ _ 0 = return []
iteraPermutaIntercambios padres tC porcentaje n = do
    rp <- randIntRango 0 porcentaje
    inter <- permutacionIntercambio (padres!!rp) tC
    inters <- iteraPermutaIntercambios padres tC porcentaje (n-1)
    return (inter:inters)

ejecutaPermutacionInter :: [[a]] -> Int -> [(String, Int)] -> IO [[a]]
ejecutaPermutacionInter padres tC mezcla = do
    let porcentaje = (snd (mezcla!!0))-1
    r <- iteraPermutaIntercambios padres (tC-1) porcentaje (snd (mezcla!!5))
    return r



--------------------------------------------------------------------------------------------------------------------------

--PERMUTACIÓN POR INSERCIÓN: se cambia un gen de una posición a otra especificada


--Input: lista con todos los padres, tamaño de cromosoma y el porcentaje de veces que se ejecutará esta combinación del total de mutaciones/combinaciones
--       n es el número de permutaciones que queremos obtener
--Proceso: muta, para un número de padres concreto (según el porcentaje asignado a esta permutación), el cromosoma
--          recibiendo la posición donde se encuentra un gen e insertándola en otra especificada
--Output: lista de padres mutados


permutacioninser :: [a] -> Int -> Int -> [a]   --Recibe el cromosoma la posición donde insertar el gen y la posicion del gen a insertar
permutacioninser xs pos1 pos2 = (take (pos1+1) xs) ++ [xs !! pos2] ++ (drop (pos1+1) (deleteAt pos2 xs))

iteraPermutacionInser :: [[a]] -> Int -> Int -> Int -> IO [[a]]
iteraPermutacionInser _ _ _ 0 = return []
iteraPermutacionInser padres tC porcentaje n = do
    rp <- randIntRango 0 porcentaje
    rtc1 <- randIntRango 0 (tC)
    rtc2 <- randIntRango 0 (tC)
    let inser = permutacioninser (padres!!rp) rtc1 rtc2
    insers <- iteraPermutacionInser padres tC porcentaje (n-1)
    return (inser:insers)

ejecutaPermutacionInser :: [[a]] -> Int -> [(String, Int)] -> IO [[a]]
ejecutaPermutacionInser padres tC mezcla = do
    let porcentaje = (snd (mezcla!!0))-1
    r <- iteraPermutacionInser padres (tC-1) porcentaje (snd (mezcla!!6))
    return r

--------------------------------------------------------------------------------------------------------------------------
--permutacionmezcla :: [a] -> Int -> --Esta creo que mejor no hacerla porque tiene una componente aleatoria que tal y como es haskell veo complicada
--permutacionmezcla = 
--------------------------------------------------------------------------------------------------------------------------

--FUNCIONES AUXILIARES
posEnLista :: Eq a => a -> [a] -> Int --Funcion auxiliar que recibe un elemento y una lista que lo contiene y devuelve la posición que ocupa dicho elemento en la lista
posEnLista e xs = 
    if (elem e xs) == False 
        then error "El elemento no se encuentra en la lista"
    else length (takeWhile (/=e) xs)
--------------------------------------------------------------------------------------------------------------------------    
ciclo :: Eq a => [a] -> [a] -> Int -> [a] -> [a] --Función auxiliar que recibe dos cromosomas , un entero y una lista vacía en principio y devuelve un ciclo del primero comenzando en la posición introducida
ciclo xs ys pos zs = if elem (xs!!pos) zs then zs
    else ciclo xs ys (posEnLista (xs!!pos) ys) (zs++[xs!!pos])

generaNumAleatorioRango _ _ = 2.1

seleccionRuleta :: Eq a => [[a]] -> Int -> ([a] -> Double) -> [[a]] --Este metodo de selección debe utilizarse en funciones de maximización
seleccionRuleta xss it fitness = [seleccionRuletaAux listaTuplas (generaNumAleatorioRango (0) (sum (map fitness xss))) 0.0 | x <- [1..it]] where
    listaTuplas = zip xss (map fitness xss)

seleccionRuletaAux :: Eq a => [([a],Double)] -> Double -> Double -> [a]
seleccionRuletaAux (xs:xss) num acum =
    if (num > (acum+(snd xs))) 
        then seleccionRuletaAux  xss num (acum + (snd xs))
    else fst xs

                                                                    
seleccionElitistaMaximizar :: Eq a => [[a]] -> Int -> ([a] -> Double) -> [[a]] --Recibe la poblacion de la iteracion anterior, el número de individuos a seleccionar, la funcion fitness y devuelve los individuos seleccionados 
seleccionElitistaMaximizar xss it fitness = [fst (reverse (sortBy ordena listaTuplas) !! x) | x <- [1..it]] where
    listaTuplas = zip xss (map fitness xss)

seleccionElitistaMinimizar :: Eq a => [[a]] -> Int -> ([a] -> Double) -> [[a]] 
seleccionElitistaMinimizar xss it fitness = [fst ((sortBy ordena listaTuplas) !! x) | x <- [1..it]] where
    listaTuplas = zip xss (map fitness xss)
  
ordena :: ([a],Double) -> ([a],Double) -> Ordering
ordena (_,a) (_,b) | a<=b = LT
                   | otherwise = GT
