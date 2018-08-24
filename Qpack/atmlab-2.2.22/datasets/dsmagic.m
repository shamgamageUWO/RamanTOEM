classdef dsmagic < dynamicprops
    % imitate a structure that gets automagically updated
    methods
        function varargout = subsref(~, S)
            if ~isequal(S(1).type, '.')
                error(['atmlab:' mfilename ':invalid'], ...
                    'Only structure-type access is defined');
            end
            D = datasets('*');
            [varargout{1:nargout}] = subsref(D, S);
        end
        
        function A = subsasgn(self, S, B)
            D = datasets('*');
            [~] = subsasgn(D, S, B);
            A = self;
        end
        
        function disp(~)
            disp(datasets('*'));
        end
        
        function display(~)
            disp(datasets('*'));
        end
        
        function update_dynamic_props(self)
            fields = fieldnames(datasets('*'));
            current_properties = properties(self);
            new_properties = setdiff(fields, current_properties);
            gone_properties = setdiff(current_properties, fields);
            for field = vec2row(new_properties)
                addprop(self, field{1});
            end
            if ~isempty(gone_properties)
                logtext(atmlab('ERR'), ...
                    'Warning: due to Gerrits laziness, tab completion on datasets will henceforth contain false politives');
            end
        end

        function tf = isfield(self, f)
            D = datasets('*');
            tf = isfield(D, f);
        end

    end
end
