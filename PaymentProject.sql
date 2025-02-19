PGDMP                      }            payment Project    17.2    17.2 3                0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            !           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            "           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            #           1262    25030    payment Project    DATABASE     �   CREATE DATABASE "payment Project" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
 !   DROP DATABASE "payment Project";
                     postgres    false                        3079    25031 	   uuid-ossp 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
    DROP EXTENSION "uuid-ossp";
                        false            $           0    0    EXTENSION "uuid-ossp"    COMMENT     W   COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';
                             false    2            l           1247    25208    method_enum    TYPE     R   CREATE TYPE public.method_enum AS ENUM (
    'credit_card',
    'bank_account'
);
    DROP TYPE public.method_enum;
       public               postgres    false            c           1247    25186 	   role_enum    TYPE     U   CREATE TYPE public.role_enum AS ENUM (
    'customer',
    'admin',
    'support'
);
    DROP TYPE public.role_enum;
       public               postgres    false            i           1247    25200    status_enum    TYPE     Y   CREATE TYPE public.status_enum AS ENUM (
    'pending',
    'completed',
    'failed'
);
    DROP TYPE public.status_enum;
       public               postgres    false            f           1247    25194    transaction_type_enum    TYPE     R   CREATE TYPE public.transaction_type_enum AS ENUM (
    'payment',
    'refund'
);
 (   DROP TYPE public.transaction_type_enum;
       public               postgres    false            �            1255    25175    create_default_payment_method()    FUNCTION     )  CREATE FUNCTION public.create_default_payment_method() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO PaymentMethod (PaymentMethodID, UserID, MethodType, Details)
    VALUES (uuid_generate_v4(), NEW.UserID, 'Default', 'Auto-created payment method');
    RETURN NEW;
END;
$$;
 6   DROP FUNCTION public.create_default_payment_method();
       public               postgres    false            �            1255    25182    log_refund_event()    FUNCTION     &  CREATE FUNCTION public.log_refund_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO AuditLog (LogID, UserID, Action)
    VALUES (uuid_generate_v4(), (SELECT UserID FROM Transactions WHERE TransactionID = NEW.TransactionID), 'Refund Issued');
    RETURN NEW;
END;
$$;
 )   DROP FUNCTION public.log_refund_event();
       public               postgres    false            �            1255    25177    log_transaction_event()    FUNCTION       CREATE FUNCTION public.log_transaction_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO TransactionLog (LogID, TransactionID, Event)
    VALUES (uuid_generate_v4(), NEW.TransactionID, 'Transaction Created');
    RETURN NEW;
END;
$$;
 .   DROP FUNCTION public.log_transaction_event();
       public               postgres    false            �            1255    25179    notify_user_transaction()    FUNCTION     %  CREATE FUNCTION public.notify_user_transaction() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO Notification (NotificationID, UserID, Message, Status)
    VALUES (uuid_generate_v4(), NEW.UserID, 'Your transaction has been processed.', 'unread');
    RETURN NEW;
END;
$$;
 0   DROP FUNCTION public.notify_user_transaction();
       public               postgres    false            �            1255    25229    update_users_updated_at()    FUNCTION     �   CREATE FUNCTION public.update_users_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.UpdatedAt = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;
 0   DROP FUNCTION public.update_users_updated_at();
       public               postgres    false            �            1259    25247    accountbalance    TABLE     �   CREATE TABLE public.accountbalance (
    balanceid uuid DEFAULT gen_random_uuid() NOT NULL,
    userid uuid,
    merchantid uuid,
    balance numeric(18,4) DEFAULT 0.0000,
    currency character varying(10) DEFAULT 'USD'::character varying
);
 "   DROP TABLE public.accountbalance;
       public         heap r       postgres    false            �            1259    25231    merchant    TABLE     �  CREATE TABLE public.merchant (
    merchantid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    phonenumber character varying(15),
    isactive boolean DEFAULT true,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updatedat timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.merchant;
       public         heap r       postgres    false            �            1259    25286    paymentmethod    TABLE     	  CREATE TABLE public.paymentmethod (
    paymentmethodid uuid DEFAULT gen_random_uuid() NOT NULL,
    userid uuid NOT NULL,
    methodtype public.method_enum NOT NULL,
    details text NOT NULL,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
 !   DROP TABLE public.paymentmethod;
       public         heap r       postgres    false    876            �            1259    25267    transaction    TABLE     �  CREATE TABLE public.transaction (
    transactionid uuid DEFAULT gen_random_uuid() NOT NULL,
    userid uuid NOT NULL,
    merchantid uuid NOT NULL,
    amount numeric(18,4) NOT NULL,
    currency character varying(10) DEFAULT 'USD'::character varying,
    transactiontype public.transaction_type_enum NOT NULL,
    status public.status_enum DEFAULT 'pending'::public.status_enum,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.transaction;
       public         heap r       postgres    false    873    873    870            �            1259    25300    transactionlog    TABLE     �   CREATE TABLE public.transactionlog (
    logid uuid DEFAULT gen_random_uuid() NOT NULL,
    transactionid uuid NOT NULL,
    event character varying(255) NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
 "   DROP TABLE public.transactionlog;
       public         heap r       postgres    false            �            1259    25213    users    TABLE       CREATE TABLE public.users (
    userid uuid DEFAULT gen_random_uuid() NOT NULL,
    username character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    passwordhash character varying(255) NOT NULL,
    salt character varying(255) NOT NULL,
    phonenumber character varying(15),
    role public.role_enum DEFAULT 'customer'::public.role_enum,
    isactive boolean DEFAULT true,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updatedat timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.users;
       public         heap r       postgres    false    867    867                      0    25247    accountbalance 
   TABLE DATA           Z   COPY public.accountbalance (balanceid, userid, merchantid, balance, currency) FROM stdin;
    public               postgres    false    220   F                 0    25231    merchant 
   TABLE DATA           h   COPY public.merchant (merchantid, name, email, phonenumber, isactive, createdat, updatedat) FROM stdin;
    public               postgres    false    219   �F                 0    25286    paymentmethod 
   TABLE DATA           `   COPY public.paymentmethod (paymentmethodid, userid, methodtype, details, createdat) FROM stdin;
    public               postgres    false    222   vG                 0    25267    transaction 
   TABLE DATA           �   COPY public.transaction (transactionid, userid, merchantid, amount, currency, transactiontype, status, "timestamp") FROM stdin;
    public               postgres    false    221   �H                 0    25300    transactionlog 
   TABLE DATA           R   COPY public.transactionlog (logid, transactionid, event, "timestamp") FROM stdin;
    public               postgres    false    223   �I                 0    25213    users 
   TABLE DATA              COPY public.users (userid, username, email, passwordhash, salt, phonenumber, role, isactive, createdat, updatedat) FROM stdin;
    public               postgres    false    218   �J       s           2606    25254 "   accountbalance accountbalance_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.accountbalance
    ADD CONSTRAINT accountbalance_pkey PRIMARY KEY (balanceid);
 L   ALTER TABLE ONLY public.accountbalance DROP CONSTRAINT accountbalance_pkey;
       public                 postgres    false    220            u           2606    25256 3   accountbalance accountbalance_userid_merchantid_key 
   CONSTRAINT     |   ALTER TABLE ONLY public.accountbalance
    ADD CONSTRAINT accountbalance_userid_merchantid_key UNIQUE (userid, merchantid);
 ]   ALTER TABLE ONLY public.accountbalance DROP CONSTRAINT accountbalance_userid_merchantid_key;
       public                 postgres    false    220    220            m           2606    25243    merchant merchant_email_key 
   CONSTRAINT     W   ALTER TABLE ONLY public.merchant
    ADD CONSTRAINT merchant_email_key UNIQUE (email);
 E   ALTER TABLE ONLY public.merchant DROP CONSTRAINT merchant_email_key;
       public                 postgres    false    219            o           2606    25245 !   merchant merchant_phonenumber_key 
   CONSTRAINT     c   ALTER TABLE ONLY public.merchant
    ADD CONSTRAINT merchant_phonenumber_key UNIQUE (phonenumber);
 K   ALTER TABLE ONLY public.merchant DROP CONSTRAINT merchant_phonenumber_key;
       public                 postgres    false    219            q           2606    25241    merchant merchant_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.merchant
    ADD CONSTRAINT merchant_pkey PRIMARY KEY (merchantid);
 @   ALTER TABLE ONLY public.merchant DROP CONSTRAINT merchant_pkey;
       public                 postgres    false    219            |           2606    25294     paymentmethod paymentmethod_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.paymentmethod
    ADD CONSTRAINT paymentmethod_pkey PRIMARY KEY (paymentmethodid);
 J   ALTER TABLE ONLY public.paymentmethod DROP CONSTRAINT paymentmethod_pkey;
       public                 postgres    false    222            y           2606    25275    transaction transaction_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (transactionid);
 F   ALTER TABLE ONLY public.transaction DROP CONSTRAINT transaction_pkey;
       public                 postgres    false    221            ~           2606    25306 "   transactionlog transactionlog_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.transactionlog
    ADD CONSTRAINT transactionlog_pkey PRIMARY KEY (logid);
 L   ALTER TABLE ONLY public.transactionlog DROP CONSTRAINT transactionlog_pkey;
       public                 postgres    false    223            f           2606    25226    users users_email_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
 ?   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key;
       public                 postgres    false    218            h           2606    25228    users users_phonenumber_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phonenumber_key UNIQUE (phonenumber);
 E   ALTER TABLE ONLY public.users DROP CONSTRAINT users_phonenumber_key;
       public                 postgres    false    218            j           2606    25224    users users_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (userid);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public                 postgres    false    218            k           1259    25313    idx_merchant_email    INDEX     H   CREATE INDEX idx_merchant_email ON public.merchant USING btree (email);
 &   DROP INDEX public.idx_merchant_email;
       public                 postgres    false    219            z           1259    25316    idx_paymentmethod_userid    INDEX     T   CREATE INDEX idx_paymentmethod_userid ON public.paymentmethod USING btree (userid);
 ,   DROP INDEX public.idx_paymentmethod_userid;
       public                 postgres    false    222            v           1259    25314    idx_transaction_status    INDEX     P   CREATE INDEX idx_transaction_status ON public.transaction USING btree (status);
 *   DROP INDEX public.idx_transaction_status;
       public                 postgres    false    221            w           1259    25315    idx_transaction_timestamp    INDEX     X   CREATE INDEX idx_transaction_timestamp ON public.transaction USING btree ("timestamp");
 -   DROP INDEX public.idx_transaction_timestamp;
       public                 postgres    false    221            d           1259    25312    idx_users_email    INDEX     B   CREATE INDEX idx_users_email ON public.users USING btree (email);
 #   DROP INDEX public.idx_users_email;
       public                 postgres    false    218            �           2620    25246 $   merchant trigger_merchant_updated_at    TRIGGER     �   CREATE TRIGGER trigger_merchant_updated_at BEFORE UPDATE ON public.merchant FOR EACH ROW EXECUTE FUNCTION public.update_users_updated_at();
 =   DROP TRIGGER trigger_merchant_updated_at ON public.merchant;
       public               postgres    false    219    238            �           2620    25230    users trigger_users_updated_at    TRIGGER     �   CREATE TRIGGER trigger_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_users_updated_at();
 7   DROP TRIGGER trigger_users_updated_at ON public.users;
       public               postgres    false    238    218                       2606    25262 -   accountbalance accountbalance_merchantid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.accountbalance
    ADD CONSTRAINT accountbalance_merchantid_fkey FOREIGN KEY (merchantid) REFERENCES public.merchant(merchantid) ON DELETE CASCADE;
 W   ALTER TABLE ONLY public.accountbalance DROP CONSTRAINT accountbalance_merchantid_fkey;
       public               postgres    false    220    4721    219            �           2606    25257 )   accountbalance accountbalance_userid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.accountbalance
    ADD CONSTRAINT accountbalance_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid) ON DELETE CASCADE;
 S   ALTER TABLE ONLY public.accountbalance DROP CONSTRAINT accountbalance_userid_fkey;
       public               postgres    false    220    218    4714            �           2606    25295 '   paymentmethod paymentmethod_userid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.paymentmethod
    ADD CONSTRAINT paymentmethod_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid) ON DELETE CASCADE;
 Q   ALTER TABLE ONLY public.paymentmethod DROP CONSTRAINT paymentmethod_userid_fkey;
       public               postgres    false    218    222    4714            �           2606    25281 '   transaction transaction_merchantid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_merchantid_fkey FOREIGN KEY (merchantid) REFERENCES public.merchant(merchantid) ON DELETE CASCADE;
 Q   ALTER TABLE ONLY public.transaction DROP CONSTRAINT transaction_merchantid_fkey;
       public               postgres    false    221    219    4721            �           2606    25276 #   transaction transaction_userid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid) ON DELETE CASCADE;
 M   ALTER TABLE ONLY public.transaction DROP CONSTRAINT transaction_userid_fkey;
       public               postgres    false    218    4714    221            �           2606    25307 0   transactionlog transactionlog_transactionid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.transactionlog
    ADD CONSTRAINT transactionlog_transactionid_fkey FOREIGN KEY (transactionid) REFERENCES public.transaction(transactionid) ON DELETE CASCADE;
 Z   ALTER TABLE ONLY public.transactionlog DROP CONSTRAINT transactionlog_transactionid_fkey;
       public               postgres    false    223    221    4729               �   x�U�-�1`��S�?��l�$����#0����.�Y��`��a�Ċ�8�Vds�n��4Ν<�����q`��!����ߟk����z桭�<Y؇�|�D-Cj�	�Mc:��*X��&ֵ�C�����)$K7��@7���j9���k,d�D�n���O��$9T��o���	fG         �   x��α
�0��9y
w�r��K'}
���Nւ�^� N�?��\Dh�=7)��:�T�]Ԑ��R���z�E���s�u1��%c�9x�!1 ��s#�H2d=���5e�HМT�BH�ܸ�b-ɜ�e)��Qܷ�bl
��q��O�CK         �   x���=N1�z�\��رcϖ��i�8��-h
nO
$��y����s�U����W�P9#`��0y�ű�y5�=`�=@��2t�Դĵ��~
����ׯ����9=��ϯ�P"�D�r�x�t$;l�d��4,��9�Vp���e���x�ZF+xs�c@S��b�dK����#�>/���~n��Cg�� *���(fp��Z���Fu�1���6�\g��p����u���(������x>���@�>           x���1��1��:s
.�_�c'��� ���N����)���d����W<~�z	�y�)^�2��cﾋSc�s�҃ �t����4��DuK^���J����0��һR��"��߾���yY����/���m���
�@����xg�FmU�͖g�1�bY�l#M��Y�d���Ψ����1��wOkƝ���#�1L� ��i�:541��c���>�c�z���w�1��H �O�SvKO�Ɇ�i=���"�6��x� &�����y~�U��z~d��n��_zG��           x���AN1���)zW�;v�����8�H�"��E�u�@]����.�Ӑ�к�p�A0#�"6L�I�J�A�j܊��ʱ�mn/�v��~?n��q=��cl�� !d:�|�tA9k�B�7�֨�*��hMP�I�
G��������Њ�8���E�廙���M�9%�$�{_j�P��	$�]�z��h�J؊�.:�T��0o�-�?qp��v΂���T���֯�*>�at��Y�8�#-�FX�П_w�рX*E�]��8�#�z�����Ȏ         �   x��нj�0�Y~�������ԖN�N]��J�vdl������2�g�8�,z�b�ZDE&9k�+�D)>jwy�Y��|ɿ4NC>pEGK��i�e��s:)�аn��R�n�u���Z�<�U�DA�'��(��A[m��hK6�kE�R@�H�{�ѡ�C��k��N��+�]�7�����_f&B�z)����٢�����c
܆(�j��a{#�xרw��wb�u��>��>4M���     