function lab1met()
clc;
debug=1;
findMax = 0; 
startMatrix = [
    1 1 1 1 1;
    1 9 7 6 9;
    1 11 5 4 2;
    1 10 10 2 5;
    1 8 2 10 9];

fprintf('Исходная матрица\n');
printMatrix(startMatrix);

M = startMatrix;


if findMax == 1 
    maxM = max(max(M));
    for i = 1 : 1: length(M(:, 1))
        M(:, i) = M(:, i)  * (-1) + maxM;
    end

    if debug == 1 
        fprintf('Матрица, после преобразований для поиска максимума\n');
        printMatrix(M);
    end
end


C = M; 
MinCols = min(C);

for i = 1 : 1 : length(MinCols)
    C(:, i) = C(:, i) - MinCols(i);
end

if debug == 1
    fprintf('Вычитаем наименьшие элементы по столбцам\n');
    printMatrix(C);
end

MinRows = min(C, [], 2);
for i = 1 : 1 : length(MinRows)
    C(i, :) = C(i, :) - MinRows(i);
end

if debug == 1 
    fprintf('Вычитаем наименьшие элементы по строкам\n');
    printMatrix(C);
end

D = C;

cols = length(MinCols);
rows = length(MinRows);
stars = zeros(rows, cols);

for i = 1: 1: cols
    for j = 1 : 1 : rows
        if D(j, i) == 0
            count = 0;
            for k = 1: 1: cols
               count = count + stars(j, k);
            end
            for k = 1: 1: rows
               count = count + stars(k, i);
            end
            if count == 0 
                stars(j, i) = 1;
            end 
        end
    end 
end

if debug == 1 
    fprintf('Начальная система независимых нулей\n');
    printSNN(D, stars)
end

k = sum(stars, 'all');
if debug == 1
    fprintf('k = %d\n', k);
end 

iteration = 1;
while k < cols
    if debug == 1
        fprintf('--- %d итерация алгоритма---\n', iteration);
    end 

    selection = zeros(rows, cols);
    strihMatrix = zeros(rows, cols);
    selectedColumns = sum(stars);
    for i = 1: 1: cols
        if selectedColumns(i) == 1 
            selection(:, i) = selection(:, i) + 1;
        end 
    end

    selectedRows = zeros(rows);


    if debug == 1 
        fprintf('Выделяем столбцы, в которых содержится 0*\n');
        printFull(D, stars, strihMatrix, selectedColumns, selectedRows);
    end

    loop = 1;
    strih = [-1, -1];
    while loop == 1 
        if debug == 1 
            fprintf('Ищем 0 среди невыделенных элементов\n');
        end
        strih = findStrih(D, selection);

        if strih(1) == -1
            h = -1;
            for i = 1: 1: cols
                for j = 1 : 1 : rows
                    if selection(j, i) == 0
                        if D(j, i) < h || h == -1
                            h = D(j,i);
                        end
                    end
                end 
            end

    
            for i = 1: 1: cols
                if selectedColumns(i) == 0
                    D(:, i) = D(:, i) - h;
                end 
            end
            for i = 1: 1: rows
                if selectedRows(i) == 1
                    D(i, :) = D(i, :) + h;
                end 
            end

            if debug == 1 
                fprintf('Среди невыделенных элемнетов нет нулей, преобразуем матрицу\n');
                printFull(D, stars, strihMatrix, selectedColumns, selectedRows);
            end

            strih = findStrih(D, selection);
        end
    
        strihMatrix(strih(1), strih(2)) = 1;


        if debug == 1 
            fprintf('Обозначаем найденный нуль 0-штрих\n');
            printFull(D, stars, strihMatrix, selectedColumns, selectedRows);
        end

        j = strih(1);
        star = [-1 -1];
        for i = 1: 1: cols
           if stars(j, i ) == 1
               star(1) = j;
               star(2) = i;
           end 
        end

        if star(1) == -1
            loop = 0;
        else
            selection(:, star(2)) = selection(:, star(2)) - 1;
            selectedColumns(star(2)) = 0;
            selection(star(1), :) = selection(star(1), :) + 1; 
            selectedRows(star(1)) = 1;
            if debug == 1 
                fprintf('В рдной строке с 0-штрих есть 0*, перебрасываем выделение\n');
                printFull(D, stars, strihMatrix, selectedColumns, selectedRows);
            end
        end
    end


    if debug == 1 
        fprintf('Строим L цепочку: ');
    end

    i = strih(1);
    j = strih(2);
    strihFlag = 1;
    while i > 0 && j > 0 && i <= rows && j <= cols
           strihMatrix(i, j) = 0;
           stars(i, j) = 1;
           fprintf("(%d, %d) ", i, j);
           k = 1;
           while k <=rows  && (stars(k, j) ~= 1 || k == i)
               k = k+1;
           end
           if (k <= rows)  
               l = 1;
               while l <= cols && (strihMatrix(k, l) ~= 1 || l == j)
                   l = l+1;
               end

               if l <= cols
                   stars(k,j) = 0;
                   fprintf("-> (%d, %d) -> ", k, j);
               end
               j = l;
           end
           i = k;
    end

    fprintf("\n");


    k = sum(stars, 'all');
    if debug == 1
        fprintf('Текущая система независимых нулей\n');
        printSNN(D, stars); 
        fprintf('k = %d\n', k);
    end

    iteration = iteration + 1;

end

    fprintf('Конечная система независимых нулей\n');
    printSNN(D, stars);


    fprintf('X = \n');
    printMatrix(stars);

    result = 0;
    for i = 1:1:cols
        for j = 1:1:rows
            if stars(j, i) == 1 
                result = result + startMatrix(j, i);
            end
        end
    end

    fprintf("Результат = %d\n", result)
end 

function [strih] = findStrih(D, selection) 
    strih = [-1 -1];
    cols = length(D(1, :));
    rows = length(D(:, 1));
    for i = 1: 1: cols
        for j = 1 : 1 : rows
           if selection(j, i) == 0 && D(j, i) == 0 
                strih(1) = j;
                strih(2) = i;
                return;
           end
        end 
    end
end

function [] = printSNN(M, stars)
    cols = length(M(1, :));
    rows = length(M(:, 1));

    for i = 1: 1: rows
        for j =1: 1: cols
            if stars(i, j) == 1 
                fprintf("*\t");
            else
                fprintf(" \t");
            end
        end
        fprintf('\n');
        for j =1: 1: cols 
            fprintf("%d\t", M(i, j))
        end
        fprintf('\n');
    end

end

function [] = printFull(M, stars, strihMatrix, selectedCols, selectedRows)
    cols = length(M(1, :));
    rows = length(M(:, 1));

    for i = 1: 1: rows
        for j =1: 1: cols
            if stars(i, j) == 1 
                fprintf("*\t");
            elseif strihMatrix(i, j) == 1
                fprintf("'\t")
            else
                fprintf(" \t");
            end
      
        end
        
        fprintf('\n');
        for j =1: 1: cols 
            fprintf("%d\t", M(i, j))
        end
        if selectedRows(i) == 1
            fprintf("+\t")
        end
        fprintf('\n');
    end

    for i = 1 : 1: cols
        if selectedCols(i) == 1
            fprintf("+\t")
        else 
            fprintf(" \t")
        end 
    end
    fprintf('\n');

end


function [] = printMatrix(M) 
    fprintf([repmat('%d\t', 1, size(M, 2)) '\n'], M')
end