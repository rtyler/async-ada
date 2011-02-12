--
--  epoll.adb - Loose binding on top of the epoll(7) interface in the Linux
--  kernel
--


package body Epoll is

    procedure Register (This : in out Hub; Descriptor : in C.int; Cb : in Callback) is
        Event : aliased Epoll_Event;
    begin
        Validate_Hub (This);

        Event.Events := EPOLLIN;
        Event.Data.Fd := Descriptor;

        declare
            Status : C.int;
        begin
            Status := Epoll_Ctl (This.Epoll_fd, EPOLL_CTL_ADD, Descriptor, Event'Access);

            if Status = -1 then
                raise Descriptor_Registration_Falied;
            end if;
        end;

        Callback_Registry.Insert (This.Callbacks, Descriptor, Cb);
    end Register;

    procedure Run (This : in Hub) is
    begin
        null;
    end Run;

    function Create return Hub is
        Created_Hub : Hub;
        Epoll_Fd : C.int;
    begin
        -- The "size" argument for Epoll_Create is unused, so we'll just
        -- default it to 10, because hey why not
        Epoll_Fd := Epoll_Create (10);

        if Epoll_Fd = -1 then
            raise Hub_Create_Failed;
        end if;

        Created_Hub.Epoll_Fd := Epoll_Fd;

        return Created_Hub;
    end Create;

    procedure Validate_Hub (H : in Hub) is
    begin
        if H.Epoll_Fd < 0 then
            raise Hub_Invalid;
        end if;
    end Validate_Hub;

end Epoll;
